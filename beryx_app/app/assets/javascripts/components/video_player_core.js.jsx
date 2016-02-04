/*global React:false, Hls:false, VideoPlayerControlBar:false, BeryxUtil:false */
/*exported VideoPlayerCore */

var VideoPlayerCore = React.createClass({
  propTypes: {
    src: React.PropTypes.string.isRequired,
    videoId: React.PropTypes.number.isRequired,
    prevPosition: React.PropTypes.number
  },
  getInitialState() {
    return {
      duration: 0,
      currentTime: 0,
      isPlaying: false,
      isFullScreen: false,
      volume: 0.5,
      prevPositionBarDone: false,
      isMiscMenuOpened: false
    };
  },
  componentDidMount() {
    var video = this.refs.video;
    video.addEventListener("timeupdate", this.onTimeUpdate);
    video.addEventListener("play", this.onPlay);
    video.addEventListener("pause", this.onPause);
    video.addEventListener("volumechange", this.onVolumeChange);
    this.onVolumeChange();

    var hasHlsNativeSupport = !!document.createElement("video")
      .canPlayType("application/vnd.apple.mpegURL");
    if (!hasHlsNativeSupport) {
      if (Hls.isSupported()) {
        var hls = new Hls();
        hls.loadSource(location.protocol + "//" + location.host + this.props.src);
        hls.attachMedia(video);
      }
    }
    window.addEventListener("beforeunload", this.sendCurrentTime);
  },
  componentWillUnmount() {
    var video = this.refs.video;
    video.removeEventListener("timeupdate", this.onTimeUpdate);
    video.removeEventListener("play", this.onPlay);
    video.removeEventListener("pause", this.onPause);
    video.removeEventListener("volumechange", this.onVolumeChange);
    window.removeEventListener("beforeunload", this.sendCurrentTime);
  },
  sendCurrentTime() {
    $.ajax({
      url: `/videos/${this.props.videoId}/play_history`,
      type: "POST",
      dataType: "json",
      data: { position: this.state.currentTime.toFixed() }
    }); // ignore response
  },
  onTimeUpdate() {
    var video = this.refs.video;
    this.setState({duration: video.duration, currentTime: video.currentTime});
  },
  onPlay() {
    this.setState({isPlaying: true});
  },
  onPause() {
    this.setState({isPlaying: false});
  },
  onVolumeChange() {
    this.setState({volume: this.refs.video.volume});
    this.forceUpdate();
  },
  changeVolume(volume) {
    this.refs.video.volume = volume;
    this.setState({volume: volume});
    this.forceUpdate();
  },
  togglePause() {
    var video = this.refs.video;
    video.paused ? video.play() : video.pause();
  },
  seekToTime(sec) {
    var video = this.refs.video;
    video.currentTime = sec;
  },
  setPlaybackRate(rate) {
    var video = this.refs.video;
    video.playbackRate = rate;
  },
  requestFullScreen() {
    var elem = this.refs.player;
    if (elem.requestFullscreen) {
      elem.requestFullscreen();
    } else if (elem.msRequestFullscreen) {
      elem.msRequestFullscreen();
    } else if (elem.mozRequestFullScreen) {
      elem.mozRequestFullScreen();
    } else if (elem.webkitRequestFullscreen) {
      elem.webkitRequestFullscreen();
    }
  },
  exitFullScreen() {
    if (document.exitFullscreen) {
      document.exitFullscreen();
    } else if (document.msExitFullscreen) {
      document.msExitFullscreen();
    } else if (document.mozCancelFullScreen) {
      document.mozCancelFullScreen();
    } else if (document.webkitExitFullscreen) {
      document.webkitExitFullscreen();
    }
  },
  toggleFullScreen() {
    if(this.state.isFullScreen) {
      this.exitFullScreen();
      this.setState({isFullScreen: false});
    } else {
      this.requestFullScreen();
      this.setState({isFullScreen: true});
    }
  },
  playFromPrevPosition() {
    this.setState({ prevPositionBarDone: true });
    this.seekToTime(this.props.prevPosition);
  },
  disappearPrevPositionBar() {
    this.setState({ prevPositionBarDone: true });
  },
  toggleMiscMenu() {
    this.setState({ isMiscMenuOpened: !this.state.isMiscMenuOpened });
  },
  _renderPlayFromHistory() {
    if(this.props.prevPosition && !this.state.prevPositionBarDone) {
      var pos = BeryxUtil.secToTime(this.props.prevPosition);
      return (
        <div className="player-prev-position-bar">
          <p>
            Start playing from {pos}?
            <button className="btn btn-primary" onClick={this.playFromPrevPosition}>Yes</button>
            <button className="btn" onClick={this.disappearPrevPositionBar}>No</button>
          </p>
        </div>
      );
    }
  },
  _onClickOverlay(e) {
    if(this.state.isMiscMenuOpened) {
      this.setState({ isMiscMenuOpened: false });
    } else {
      e.preventDefault();
    }
  },
  render() {
    return (
      <div className="player-core" ref="player">
        <div className="player-overlay" onClick={this._onClickOverlay} style={this.state.isMiscMenuOpened ? {} : {display:"none"} }></div>
        {this._renderPlayFromHistory()}
        <div className="player-video-container">
          <video
            className="player-video" src={this.props.src}
            ref="video"
          />
        </div>
        <VideoPlayerControlBar
          duration={this.state.duration} currentTime={this.state.currentTime}
          volume={this.state.volume}
          togglePause={this.togglePause} isPlaying={this.state.isPlaying}
          seekToTime={this.seekToTime} setPlaybackRate={this.setPlaybackRate}
          isFullScreen={this.state.isFullScreen} toggleFullScreen={this.toggleFullScreen}
          changeVolume={this.changeVolume} toggleMiscMenu={this.toggleMiscMenu}
          isMiscMenuOpened={this.state.isMiscMenuOpened}
        />
      </div>
    );
  }
});

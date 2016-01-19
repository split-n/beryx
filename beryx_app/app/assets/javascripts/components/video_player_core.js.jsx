var VideoPlayerSeekBar = React.createClass({
  propTypes: {
    duration: React.PropTypes.number.isRequired,
    currentTime: React.PropTypes.number.isRequired,
    isPlaying: React.PropTypes.bool.isRequired,
    togglePause: React.PropTypes.func.isRequired,
    seekToTime: React.PropTypes.func.isRequired
  },
  _zeroPad(val, dig) {
    return ("0".repeat(dig)+val).slice(-dig);
  },
  _secToTime(sec) {
    var m = Math.floor(sec/60);
    var s = Math.floor(sec%60);
    var mDig = 2;
    var sDig = 2;
    if(m >= 100) {
      mDig = 3;
    }
    return `${this._zeroPad(m, mDig)}:${this._zeroPad(s, sDig)}`;
  },
  _getCurrent() {
    return this._secToTime(this.props.currentTime);
  },
  _getDuration() {
    return this._secToTime(this.props.duration);
  },
  _renderPlayButton() {
    var classes;
    if(this.props.isPlaying) {
      classes = "glyphicon glyphicon-pause"
    } else {
      classes = "glyphicon glyphicon-play"
    }
    return (
      <button className="btn" onClick={this.props.togglePause}>
        <span className={classes}></span>
      </button>
    );
  },
  _seekRelative(sec) {
    console.log(`seek to ${sec}`)
    this.props.seekToTime(this.props.currentTime + sec);
  },
  _renderJumpButtons() {
    return (
      <div>
        <button className="btn" onClick={this._seekRelative.bind(this, -30)}>-30</button>
        <button className="btn" onClick={this._seekRelative.bind(this, -15)}>-15</button>
        <button className="btn" onClick={this._seekRelative.bind(this, 15)}>+15</button>
        <button className="btn" onClick={this._seekRelative.bind(this, 30)}>+30</button>
      </div>
    );
  },
  render() {
    return (
      <div id="playing-seekbar">
        {this._renderPlayButton()}
        {this._renderJumpButtons()}
        <span id="playing-seekbar-time">{this._getCurrent()}/{this._getDuration()}</span>
      </div>
    );
  }
});

var VideoPlayerCore = React.createClass({
  propTypes: {
    src: React.PropTypes.string.isRequired
  },
  getInitialState() {
    return {
      duration: 0,
      currentTime: 0,
      isPlaying: false
    }
  },
  componentDidMount() {
    var video = this.refs.video;
    video.addEventListener("timeupdate", this.onTimeUpdate);
    video.addEventListener("play", this.onPlay);
    video.addEventListener("pause", this.onPause);

    var hasHlsNativeSupport = !!document.createElement('video').canPlayType('application/vnd.apple.mpegURL');
    if(!hasHlsNativeSupport) {
      if(Hls.isSupported()) {
        var hls = new Hls();
        hls.loadSource(location.protocol + "//" + location.host + this.props.src);
        hls.attachMedia(video);
        hls.on(Hls.Events.MANIFEST_PARSED,function() {
          video.play();
        });
      }
    }
  },
  componentWillUnmount() {
    var video = this.refs.video;
    video.removeEventListener("timeupdate", this.onTimeUpdate);
    video.removeEventListener("play", this.onPlay);
    video.removeEventListener("pause", this.onPause);
  },
  onTimeUpdate() {
    var video = this.refs.video;
    this.setState({duration: video.duration, currentTime: video.currentTime});
  },
  onPlay() {
    var video = this.refs.video;
    this.setState({isPlaying: true});
  },
  onPause() {
    var video = this.refs.video;
    this.setState({isPlaying: false});
  },
  togglePause() {
    var video = this.refs.video;
    video.paused ? video.play() : video.pause();
  },
  seekToTime(sec) {
    var video = this.refs.video;
    video.currentTime = sec;
  },
  render() {
    return (
      <div>
        <video id="playing-video" src={this.props.src} preload="none" onclick="this.play()" controls="controls" ref="video"/>
        <VideoPlayerSeekBar
        duration={this.state.duration} currentTime={this.state.currentTime}
        togglePause={this.togglePause} isPlaying={this.state.isPlaying}
        seekToTime={this.seekToTime}
        />
      </div>
    );
  }
});

/*global React:false, Hls:false, VideoPlayerControlBar:false */
/*exported VideoPlayerCore */

var VideoPlayerCore = React.createClass({
  propTypes: {
    src: React.PropTypes.string.isRequired
  },
  getInitialState() {
    return {
      duration: 0,
      currentTime: 0,
      isPlaying: false
    };
  },
  componentDidMount() {
    var video = this.refs.video;
    video.addEventListener("timeupdate", this.onTimeUpdate);
    video.addEventListener("play", this.onPlay);
    video.addEventListener("pause", this.onPause);

    var hasHlsNativeSupport = !!document.createElement("video")
      .canPlayType("application/vnd.apple.mpegURL");
    if (!hasHlsNativeSupport) {
      if (Hls.isSupported()) {
        var hls = new Hls();
        hls.loadSource(location.protocol + "//" + location.host + this.props.src);
        hls.attachMedia(video);
        hls.on(Hls.Events.MANIFEST_PARSED, function () {
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
    this.setState({isPlaying: true});
  },
  onPause() {
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
  setPlaybackRate(rate) {
    var video = this.refs.video;
    video.playbackRate = rate;
  },
  render() {
    return (
      <div>
        <video
          id="playing-video" src={this.props.src}
          preload="none" controls="controls"
          ref="video"
        />
        <VideoPlayerControlBar
          duration={this.state.duration} currentTime={this.state.currentTime}
          togglePause={this.togglePause} isPlaying={this.state.isPlaying}
          seekToTime={this.seekToTime} setPlaybackRate={this.setPlaybackRate}
        />
      </div>
    );
  }
});

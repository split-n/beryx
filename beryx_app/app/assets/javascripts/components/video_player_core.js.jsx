var VideoPlayerSeekBar = React.createClass({
  propTypes: {
    duration: React.PropTypes.number.isRequired,
    currentTime: React.PropTypes.number.isRequired
  },
  render: function() {
    return (
      <div id="playing-seekbar">
        <span id="playing-seekbar-time">{this.props.currentTime}/{this.props.duration}</span>
      </div>
    )
  }
});

var VideoPlayerCore = React.createClass({
  propTypes: {
    src: React.PropTypes.string.isRequired
  },
  getInitialState() {
    return {
      duration: 0,
      currentTime: 0
    }
  },
  componentDidMount() {
    var video = this.refs.video;
    video.addEventListener("timeupdate", this.onTimeUpdate);

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
  },
  onTimeUpdate: function() {
    var video = this.refs.video;
    this.setState({duration: video.duration, currentTime: video.currentTime});
  },
  render: function() {
    return (
      <div>
        <video id="playing-video" src={this.props.src} preload="none" onclick="this.play()" controls="controls" ref="video"/>
        <VideoPlayerSeekBar duration={this.state.duration} currentTime={this.state.currentTime}/>
      </div>
    );
  }
});

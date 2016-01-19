var VideoPlayerSeekBar = React.createClass({
  propTypes: {
    duration: React.PropTypes.number.isRequired,
    currentTime: React.PropTypes.number.isRequired
  },
  _zeroPad: function(val, dig) {
    return ("0".repeat(dig)+val).slice(-dig)
  },
  _secToTime: function(sec) {
    var m = Math.floor(sec/60);
    var s = Math.floor(sec%60);
    var mDig = 2;
    var sDig = 2;
    if(m >= 100) {
      mDig = 3;
    }
    return `${this._zeroPad(m, mDig)}:${this._zeroPad(s, sDig)}`;
  },
  getCurrent: function() {
    return this._secToTime(this.props.currentTime);
  },
  getDuration: function() {
    return this._secToTime(this.props.duration);
  },
  render: function() {
    return (
      <div id="playing-seekbar">
        <span id="playing-seekbar-time">{this.getCurrent()}/{this.getDuration()}</span>
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

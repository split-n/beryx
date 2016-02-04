/*global React:false, BeryxUtil:false */
/*exported VideoPlayerControlBar */

var VideoPlayerControlBar = React.createClass({
  propTypes: {
    duration: React.PropTypes.number.isRequired,
    currentTime: React.PropTypes.number.isRequired,
    volume: React.PropTypes.number.isRequired,
    isPlaying: React.PropTypes.bool.isRequired,
    togglePause: React.PropTypes.func.isRequired,
    seekToTime: React.PropTypes.func.isRequired,
    setPlaybackRate: React.PropTypes.func.isRequired,
    isFullScreen: React.PropTypes.bool.isRequired,
    toggleFullScreen: React.PropTypes.func.isRequired,
    changeVolume: React.PropTypes.func.isRequired
  },
  getInitialState() {
    return {isMiscMenuOpened: false};

  },
  _getCurrent() {
    return BeryxUtil.secToTime(this.props.currentTime);
  },
  _getDuration() {
    return BeryxUtil.secToTime(this.props.duration);
  },
  _renderPlayButton() {
    var classes;
    if (this.props.isPlaying) {
      classes = "glyphicon glyphicon-pause";
    } else {
      classes = "glyphicon glyphicon-play";
    }
    return (
      <button className="btn player-controller-play-button" onClick={this.props.togglePause}>
        <span className={classes}/>
      </button>
    );
  },
  _seekRelative(sec) {
    this.props.seekToTime(this.props.currentTime + sec);
  },
  _renderJumpButtons() {
    var secs = [-30, -15, 15, 30];
    var buttons = secs.map(s => {
      return (
        <button
          className="btn" key={s}
          onClick={this._seekRelative.bind(this, s)}
        >{s}</button> );
    });
    return (
      <div className="player-controller-jump-buttons">
        {buttons}
      </div>
    );
  },
  _PlaybackRateSelectHandler() {
    var select = this.refs.pl_select;
    var rate = parseFloat(select.value);
    this.props.setPlaybackRate(rate);
  },
  _renderPlaybackRateSelects() {
    var rates = [0.8, 1, 1.1, 1.25, 1.4, 1.5, 1.75, 2];
    var options = rates.map(r => {
      var f = r.toFixed(2);
      return <option value={f} key={f}>x{f}</option>;
    });
    return (
      <select className="player-controller-select-rate" ref="pl_select"
        defaultValue="1.00" onChange={this._PlaybackRateSelectHandler}
      >{options} </select>
    );
  },
  _renderFullScreenButton() {
    var iconClasses;
    if(this.props.isFullScreen) {
      iconClasses = "glyphicon glyphicon-resize-small";
    } else {
      iconClasses = "glyphicon glyphicon-fullscreen";
    }
    return (
     <button className="btn" onClick={this.props.toggleFullScreen}>
       <span className={iconClasses}/>
     </button>
    );
  },
  _renderMiscMenu() {
    var menuStyle = { display:  this.state.isMiscMenuOpened ? "block" : "none" };
    var volumeButtonClasses;
    if(this.props.volume === 0) {
      volumeButtonClasses = "glyphicon glyphicon-volume-off";
    } else {
      volumeButtonClasses = "glyphicon glyphicon-volume-up";
    }
    return (
      <div className="player-controller-misc-menu"
         style={menuStyle} >
        <button className="btn player-controller-volume-button" onClick={this._toggleMute}>
          <span className={volumeButtonClasses} />
        </button>
        <input type="range" className="player-controller-volume-bar"
           max="100"
           ref="volumebar" onChange={this._onVolumeBarMoved} />
        {this._renderPlaybackRateSelects()}
      </div>
      );

  },
  _onSeekBarMoved() {
    this.props.seekToTime(this.refs.seekbar.value);
  },
  _onVolumeBarMoved() {
    this.props.changeVolume(this.refs.volumebar.value / 100);
  },
  _toggleMiscMenu() {
    this.setState({isMiscMenuOpened: !this.state.isMiscMenuOpened});
  },
  _toggleMute() {
    if(this.props.volume === 0) {
      if(this.state.prevVolume) {
        this.props.changeVolume(this.state.prevVolume);
        this.setState({prevVolume: undefined});
      } // do nothing if prevVolume is not saved
    } else {
      this.setState({prevVolume: this.props.volume});
      this.props.changeVolume(0);
    }
  },
  componentWillUpdate() {
    this.refs.seekbar.value = this.props.currentTime;
    this.refs.volumebar.value = this.props.volume * 100;
  },
  render() {
    return (
      <div className="player-controller">
        <div className="player-controller-left">
          {this._renderPlayButton()}
          {this._renderJumpButtons()}
        </div>
        <div className="player-controller-center">
          <input type="range" className="player-controller-seekbar"
             ref="seekbar" max={this.props.duration}
             onChange={this._onSeekBarMoved}
          />
        </div>
        <div className="player-controller-right">
          <span className="player-controller-display-time">
            {this._getCurrent()}/{this._getDuration()}</span>
          <button className="btn player-controller-misc-button"
            onClick={this._toggleMiscMenu}
          >
            <span className="glyphicon glyphicon-option-vertical"
            />
          </button>
          {this._renderMiscMenu()}
          {this._renderFullScreenButton()}
        </div>
      </div>
    );
  }
});

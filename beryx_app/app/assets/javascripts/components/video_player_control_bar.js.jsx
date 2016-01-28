/*global React:false */
/*exported VideoPlayerControlBar */

var VideoPlayerControlBar = React.createClass({
  propTypes: {
    duration: React.PropTypes.number.isRequired,
    currentTime: React.PropTypes.number.isRequired,
    isPlaying: React.PropTypes.bool.isRequired,
    togglePause: React.PropTypes.func.isRequired,
    seekToTime: React.PropTypes.func.isRequired,
    setPlaybackRate: React.PropTypes.func.isRequired,
    isFullScreen: React.PropTypes.bool.isRequired,
    toggleFullScreen: React.PropTypes.func.isRequired
  },
  _zeroPad(val, dig) {
    return ("0".repeat(dig) + val).slice(-dig);
  },
  _secToTime(sec) {
    var m = Math.floor(sec / 60);
    var s = Math.floor(sec % 60);
    var mDig = 2;
    var sDig = 2;
    if (m >= 100) {
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
  _renderSeekBar() {
    return (
      <div className="player-controller-seekbar">
        <div className="player-controller-seekbar-fill">&nbsp;</div>

      </div>
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
  render() {
    return (
      <div className="player-controller">
        <div className="player-controller-left">
          {this._renderPlayButton()}
          {this._renderJumpButtons()}
        </div>
        <div className="player-controller-center">
          {this._renderSeekBar()}
        </div>
        <div className="player-controller-right">
          {this._renderPlaybackRateSelects()}
          <span className="player-controller-display-time">
            {this._getCurrent()}/{this._getDuration()}</span>
          {this._renderFullScreenButton()}
        </div>
      </div>
    );
  }
});

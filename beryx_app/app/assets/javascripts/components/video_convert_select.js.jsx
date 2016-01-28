/*global React:false */
/*exported VideoConvertSelect */

var VideoConvertSelect = React.createClass({
  propTypes: {
    videoId: React.PropTypes.number.isRequired,
    videoName: React.PropTypes.string.isRequired,
    onVideoSourceSupplied: React.PropTypes.func.isRequired
  },
  getInitialState() {
    return {
      disableSelectButtons: false
    };
  },
  onClickConvertMethod(method) {
    this.setState({disableSelectButtons: true});
    var params;
    switch(method) {
    case "HLS_COPY":
      break;
    case "HLS_720P_5M":
      break;
    case "HLS_720P_3M":
      break;
    }

  },
  render: function() {
    return (
        <div className="video-convert-page">
          <h1>select convert method</h1>
          <h2 className="convert-video-name">{this.props.videoName}</h2>
          <ul className="convert-method-list">
            <li><button className="btn" disabled={this.state.disableSelectButtons && "disabled"}
              onClick={this.onClickConvertMethod.bind(this, "HLS_COPY")}
                >HLS no convert</button></li>
            <li><button className="btn" disabled={this.state.disableSelectButtons && "disabled"}
              onClick={this.onClickConvertMethod.bind(this, "HLS_720P_5M")}
                >HLS 720p 5Mbps</button></li>
            <li><button className="btn" disabled={this.state.disableSelectButtons && "disabled"}
              onClick={this.onClickConvertMethod.bind(this, "HLS_720P_3M")}
                >HLS 720p 3Mbps</button></li>
          </ul>
        </div>
    );
  }
});

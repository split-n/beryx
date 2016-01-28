/*global React:false, VideoPlayerCore:false, VideoConvertSelect:false */
/*exported VideoPlayer */

var VideoPlayer = React.createClass({
  propTypes: {
    videoName: React.PropTypes.string.isRequired,
    videoId: React.PropTypes.number.isRequired
  },
  getInitialState() {
    return {};
  },
  onVideoSourceSupplied(path) {
    this.setState({videoFilePath: path});
  },
  render: function() {
    if(this.state.videoFilePath) {
      return <VideoPlayerCore src={this.state.videoFilePath} />;
    } else {
      return (
        <VideoConvertSelect
          videoId={this.props.videoId}
          videoName={this.props.videoName}
          onVideoSourceSupplied={this.onVideoSourceSupplied}
        />
      );
    }
  }
});

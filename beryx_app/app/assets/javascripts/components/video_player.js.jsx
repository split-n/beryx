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
    $.ajax({
      type: "GET",
      url: `/videos/${this.props.videoId}/play_history`,
      dataType: "json"
    }).done( (response) => {
      this.setState({
        videoFilePath: path,
        prevPosition: response.position
      });
    }).fail( () => {
        this.setState({videoFilePath: path});
    });
  },
  render: function() {
    if(this.state.videoFilePath) {
      return <VideoPlayerCore
        src={this.state.videoFilePath}
        prevPosition={this.state.prevPosition}
        videoId={this.props.videoId} />;
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

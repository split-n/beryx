/*global React:false, VideoPlayerCore:false */
/*exported VideoPlayer */

var VideoPlayer = React.createClass({
  propTypes: {
    file_name: React.PropTypes.string.isRequired,
    video_path: React.PropTypes.string.isRequired
  },
  render: function() {
    return (
        <div>
          <h1>Video Player</h1>
          <p>{this.props.file_name}</p>
          <VideoPlayerCore src={this.props.video_path} />
        </div>
    );
  }
});

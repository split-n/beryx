var VideoPlayerCore = React.createClass({
  propTypes: {
    src: React.PropTypes.string.isRequired
  },
  render: function() {
    return <video src={this.props.src} preload="none" onclick="this.play()" controls="controls"/>;
  }
});

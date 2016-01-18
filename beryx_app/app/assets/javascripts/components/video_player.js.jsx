var VideoPlayer = React.createClass({

  render: function() {
    return (
        <div>
            <h1>Video Player</h1>
            <p>{this.props.file_name}</p>
            <video src={this.props.video_path} preload="none" onclick="this.play()" controls="controls"/>
        </div>
    );
  }
});

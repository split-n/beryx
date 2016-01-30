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
      disableSelectButtons: false,
      loadingVideo: false
    };
  },
  sendConvertRequest(params) {
    $.ajax({
      type: "POST",
      url: `/videos/${this.props.videoId}/convert`,
      data: JSON.stringify(params),
      dataType: "json",
      contentType:"application/json"
    }).done((response) => {
      var video_source_path = response.video_source_path;
      this.waitUntilFound(video_source_path, () => {
        this.props.onVideoSourceSupplied(video_source_path);
      });
    }).fail((error) => {
      console.log(error);
    });
  },
  waitUntilFound(url, callback) {
    $.ajax({
      type: "HEAD",
      url: url
    }).done((data, textStatus, jqXHR ) => {
      switch(jqXHR.status) {
      case 200:
          callback();
          break;
      default:
          console.log(jqXHR);
          break;
      }
    }).fail((jqXHR) => {
      switch(jqXHR.status) {
      case 404:
        setTimeout(() => {
          console.log(`404 ${url}, retry in 3000ms`);
          this.waitUntilFound(url, callback);
        }, 3000);
        break;
      }
    });
  },
  onClickConvertMethod(method) {
    this.setState({disableSelectButtons: true, loadingVideo: true});
    var params;
    switch(method) {
    case "HLS_COPY":
      params = {convert_method: "HLS_COPY"};
      break;
    case "HLS_1080P_8M":
      params = {
        convert_method: "HLS_AVC_AAC_ENCODE",
        convert_params: {
          video_kbps: 8000-192, audio_kbps: 192,
          height: 1080, preset: "veryfast"
        }
      };
      break;
    case "HLS_720P_3M":
      params = {
        convert_method: "HLS_AVC_AAC_ENCODE",
        convert_params: {
          video_kbps: 3000-160, audio_kbps: 160,
          height: 720, preset: "fast"
        }
      };
      break;
    case "HLS_720P_1M":
      params = {
        convert_method: "HLS_AVC_AAC_ENCODE",
        convert_params: {
          video_kbps: 1000-100, audio_kbps: 128,
          height: 720, preset: "fast"
        }
      };
      break;
    case "HLS_360P_500K":
      params = {
        convert_method: "HLS_AVC_AAC_ENCODE",
        convert_params: {
          video_kbps: 500-56, audio_kbps: 56,
          height: 360, preset: "fast",
          he_aac: true
        }
      };
      break;
    default:
        console.log("invalid method");
    }

    this.sendConvertRequest(params)
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
              onClick={this.onClickConvertMethod.bind(this, "HLS_1080P_8M")}
            >HLS 1080p 8Mbps veryfast</button></li>
            <li><button className="btn" disabled={this.state.disableSelectButtons && "disabled"}
              onClick={this.onClickConvertMethod.bind(this, "HLS_720P_3M")}
                >HLS 720p 3Mbps</button></li>
            <li><button className="btn" disabled={this.state.disableSelectButtons && "disabled"}
              onClick={this.onClickConvertMethod.bind(this, "HLS_720P_1M")}
                >HLS 720p 1Mbps</button></li>
            <li><button className="btn" disabled={this.state.disableSelectButtons && "disabled"}
                        onClick={this.onClickConvertMethod.bind(this, "HLS_360P_500K")}
            >HLS 360p 500Kbps</button></li>
          </ul>
        </div>
    );
  }
});

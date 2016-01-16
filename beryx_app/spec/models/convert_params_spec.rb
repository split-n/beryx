require 'rails_helper'

describe ConvertParams::CopyHls do
  it "returns command" do
    params = ConvertParams::CopyHls.from_json("{}")
    expect(params).to be_an_instance_of ConvertParams::CopyHls

    src_file = "/path/to/src.mp4"
    dest_dir = "/paxx/to/dst"
    dest_file = "/paxx/to/dst/playlist.m3u8"

    command = params.to_command(src_file, dest_dir, dest_file)
    expect(command).to include "ffmpeg"
    expect(command).to include src_file
    expect(command).to include dest_file

  end
end
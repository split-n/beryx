require 'test_helper'

class CrawlDirectoryTest < ActiveSupport::TestCase
  test "invalid with not existed directory path" do
    Dir.stub(:exists?, false) do
      cd = CrawlDirectory.create(path: "/nowhere")
      assert cd.invalid?
    end
  end

  test "valid with existed directory path" do
    Dir.stub(:exists?, true) do
      cd = CrawlDirectory.create(path: "/found")
      assert cd.valid?
    end
  end
end

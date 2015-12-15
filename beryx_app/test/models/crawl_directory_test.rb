require 'test_helper'

class CrawlDirectoryTest < ActiveSupport::TestCase
  test "invalid with not existed directory path" do
    stub_exist(false) do
      cd = CrawlDirectory.create(path: "/nowhere/")
      assert cd.invalid?
    end
  end

  test "invalid when path blank" do
    cd = CrawlDirectory.create(path: " ")
    assert cd.invalid?

    cd = CrawlDirectory.create(path: "")
    assert cd.invalid?
  end

  test "valid with existed directory path" do
    stub_exist do
      cd = CrawlDirectory.create(path: "/found/")
      assert cd.valid?
    end
  end

  test "invalid when path isn't ended with slash" do
    stub_exist do
      cd = CrawlDirectory.create(path: "/foo")
      assert cd.invalid?
    end
  end

  test "invalid when path isn't started with slash" do
    stub_exist do
      cd = CrawlDirectory.create(path: "foo/")
      assert cd.invalid?
    end
  end

  test "invalid when other directory is included" do
    stub_exist do
      d1 = CrawlDirectory.create(path: "/foo/bar/")
      d2 = CrawlDirectory.create(path: "/foo/")
      assert d2.invalid?
    end
  end

  test "invalid when other directory includes this" do
    stub_exist do
      d1 = CrawlDirectory.create(path: "/foo/bar/")
      d2 = CrawlDirectory.create(path: "/foo/bar/baz/")
      assert d2.invalid?
    end
  end

  test "invalid when same directory found" do
    stub_exist do
      d1 = CrawlDirectory.create(path: "/foo/bar/")
      d2 = CrawlDirectory.create(path: "/foo/bar/")
      assert d2.invalid?
    end
  end

  def stub_exist(result=true)
    Dir.stub(:exist?, result) do
      yield
    end
  end
end

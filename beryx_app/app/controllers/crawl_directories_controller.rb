class CrawlDirectoriesController < ApplicationController
  def index
    @crawl_directory = CrawlDirectory.new
    @crawl_directories = CrawlDirectory.all
  end

  def create
    @crawl_directory = CrawlDirectory.new(crawl_directory_params)
    if @crawl_directory.save
      flash[:success] = "Created."
      redirect_to crawl_directories_path
    else
      @crawl_directories = CrawlDirectory.all
      render 'index'
    end
  end

  def destroy
  end

  private
  def crawl_directory_params
    params.require(:crawl_directory).permit(:path)
  end
end

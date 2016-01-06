class CrawlDirectoriesController < ApplicationController
  before_action :set_crawl_directory, only: [:show, :destroy]

  def index
    @crawl_directories = CrawlDirectory.all
  end

  def show
  end

  def new
    @crawl_directory = CrawlDirectory.new
  end

  def create
    @crawl_directory = CrawlDirectory.new(crawl_directory_params)

    if @crawl_directory.save
      redirect_to @crawl_directory, notice: 'Crawl directory was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @crawl_directory.destroy
    redirect_to crawl_directories_url, notice: 'Crawl directory was successfully destroyed.'
  end

  private
    def set_crawl_directory
      @crawl_directory = CrawlDirectory.find(params[:id])
    end

    def crawl_directory_params
      params.require(:crawl_directory).permit(:path)
    end
end

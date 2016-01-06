class CrawlDirectoriesController < ApplicationController
  before_action :set_crawl_directory, only: [:show, :edit, :update, :destroy]

  # GET /crawl_directories
  # GET /crawl_directories.json
  def index
    @crawl_directories = CrawlDirectory.all
  end

  # GET /crawl_directories/1
  # GET /crawl_directories/1.json
  def show
  end

  # GET /crawl_directories/new
  def new
    @crawl_directory = CrawlDirectory.new
  end

  # GET /crawl_directories/1/edit
  def edit
  end

  # POST /crawl_directories
  # POST /crawl_directories.json
  def create
    @crawl_directory = CrawlDirectory.new(crawl_directory_params)

    respond_to do |format|
      if @crawl_directory.save
        format.html { redirect_to @crawl_directory, notice: 'Crawl directory was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /crawl_directories/1
  # PATCH/PUT /crawl_directories/1.json
  def update
    respond_to do |format|
      if @crawl_directory.update(crawl_directory_params)
        format.html { redirect_to @crawl_directory, notice: 'Crawl directory was successfully updated.' }
        format.json { render :show, status: :ok, location: @crawl_directory }
      else
        format.html { render :edit }
        format.json { render json: @crawl_directory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /crawl_directories/1
  # DELETE /crawl_directories/1.json
  def destroy
    @crawl_directory.destroy
    respond_to do |format|
      format.html { redirect_to crawl_directories_url, notice: 'Crawl directory was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_crawl_directory
      @crawl_directory = CrawlDirectory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def crawl_directory_params
      params.require(:crawl_directory).permit(:path)
    end
end

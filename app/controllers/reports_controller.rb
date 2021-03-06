class ReportsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @search = Search.new
    # @reports = current_user.reports.order(:position, created_at: :desc)
    # Use the above query if we decide to set position to 1
    @reports = current_user.reports.order(:position) 
    @report = Report.new
  end

  def create
    @report = current_user.reports.new(report_params)
    respond_to do |format|
      @report.position = 0
      if @report.save
        format.html {redirect_to reports_path, notice: "Report Created"}
        format.js {render}
      else
        format.html {redirect_to reports_path, notice: "Report NOT Created"}
        format.js {render}
      end
    end
  end

  def show
    @report = Report.find(params[:id])
    if @report.user != current_user
      flash[:alert] = "Access Denied. You can only view receipts that belong to you."
      redirect_to reports_path
    else
      @search = Search.new
      @locations = Receipt.near([49.2314389, -123.0657958], 20, units: :km)
      @receipt = Receipt.new
    end
  end

  def edit
    @report = Report.find(params[:id])
  end

  def update
    @report = Report.find(params[:id])
    respond_to do |format|
      if @report.update(report_params)
        format.html {redirect_to reports_path, notice: "Report Updated"}
        format.js {render}
      else
        format.html {redirect_to reports_path, notice: "Invalid update parameters"}
        format.js {render}
      end
    end
  end

  def destroy
    @report = Report.find(params[:id])
    respond_to do |format|
      if @report.destroy
        format.js {render}
        format.html {redirect_to reports_path, notice: "Report Deleated"}
      else
        format.js {render}
        format.html {redirect_to reports_path, notice: "Unable to Delete"}
      end
    end
  end

  def sort
    params[:snap_report].each_with_index do |id, index|
      Report.find(id).update!(position: index + 1)
    end
    head :ok
  end

  private

  def report_params
    params.require(:report).permit(:title, :description)
  end

end

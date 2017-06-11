class QuotationsController < ApplicationController
  before_action :set_quotation, only: [:destroy, :update, :download]
  before_action :set_project, only: [:index, :new, :edit, :create, :update, :destroy]
  before_action :set_project_download, only: [:download]
  before_action :check_company
  before_action :check_auth

  # GET /quotations
  # GET /quotations.json
  def index
    @quotations = @project.quotations
  end

  # GET /quotations/new
  def new
    @quotation = Quotation.new
  end

  # POST /quotations
  # POST /quotations.json
  def create
    @quotation = Quotation.new(quotation_params)
    respond_to do |format|
      if @quotation.save
        @quotation.update_attribute(:project_id, params[:project_id])
        # Change the project's status if Pending
        if @project.status == 'Pending'
          @project.update_attribute(:status, 'Quote')
          # Send email notification about the modification of the status
          ExampleMailer.status(@project).deliver
        end
        # Send email notification to the owner of the project
        ExampleMailer.new_quotation(@project).deliver
        format.html { redirect_to @project, notice: 'Quotation was successfully created.' }
        format.json { render :show, status: :created, location: @quotation }
      else
        format.html { render :new }
        format.json { render json: @quotation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quotations/1
  # DELETE /quotations/1.json
  def destroy
    # Change the status to Pending if there is no quotation anymore
    if @project.quotations.first == @quotation && @project.quotations.size == 1 && (@project.status == 'Quote' || @project.status == 'Ongoing')
      @project.update_attribute(:status, 'Pending')
      # Send email notification about the modification of the status
      ExampleMailer.status(@project).deliver
    end
    # Set project attributes relative to the quotation with the default values
    @project.update_attribute(:confirmation, false)
    @project.update_attribute(:deadline, nil)
    @project.update_attribute(:cost, nil)
    @project.update_attribute(:currency_id, nil)
    # Destroy the quotation
    @quotation.destroy
    respond_to do |format|
      format.html { redirect_to @project, notice: 'Quotation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Download the file
  def download
    path = "#{@quotation.file_path}"
    send_file path, :x_sendfile=>true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quotation
      @quotation = Quotation.find(params[:id])
    end

    # Set the project of the file
    def set_project
      @project = Project.find(params[:project_id])
    end

    # Set the project of the file to download
    def set_project_download
      @project = Project.find(@quotation.project_id)
    end

    # Check if the current user belongs to a company or if they are an administrator or a project manager.
    def check_company
      if current_user.company == nil && !current_user.manager? && !current_user.admin?
        redirect_to new_company_path, :alert => "You have to create or be invited by a company before access to the website." and return
      end
    end

    # Check if the current user has the right to manage the client files of the current project.
    def check_auth
      if @project.project_owner_id != current_user.id && !current_user.admin? && current_user.id != @project.project_manager_id && !(current_user.company == @project.project_owner.company && current_user.company_admin?)
        redirect_to projects_path, :alert => "Access denied." and return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quotation_params
      params.require(:quotation).permit(:file_path, :project_id, :name, :cost, :deadline, :currency_id)
    end
end

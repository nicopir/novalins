class OutputFilesController < ApplicationController
  before_action :set_output_file, only: [:destroy, :update, :download]
  before_action :set_project, only: [:index, :new, :edit, :create, :update, :destroy]
  before_action :set_project_download, only: [:download]
  before_action :check_company
  before_action :check_auth_admin, only: [:new, :create, :destroy]
  before_action :check_auth, only: [:index, :download]

  # GET /output_files
  # GET /output_files.json
  def index
    @output_files = @project.outputs
  end

  # GET /output_files/new
  def new
    @output_file = OutputFile.new
  end

  # POST /output_files
  # POST /output_files.json
  def create
    @output_file = OutputFile.new(output_file_params)
    respond_to do |format|
      if @output_file.save
        @output_file.update_attribute(:project_id, @project.id)
        # Change the project's status to Delivered if not closed
        if @project.status != 'Delivered' && @project.status != 'Closed'
          @project.update_attribute(:status, 'Delivered')
          # Send email notification about the modification of the status
          ExampleMailer.status(@project).deliver
        end
        # Send email notification to the owner of the project
        ExampleMailer.new_output_file(@project).deliver
        format.html { redirect_to @project, notice: 'Delivery was successfully created.' }
        format.json { render :show, status: :created, location: @output_file }
      else
        format.html { render :new }
        format.json { render json: @output_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /output_files/1
  # DELETE /output_files/1.json
  def destroy
    # Check the new status if there is no invoice anymore
    if @project.output_files.size == 1
      if @project.invoices.size == 0 
        if @project.quotations.size == 0
          @project.update_attribute(:status, 'Pending')
        elsif @project.confirmation?
          @project.update_attribute(:status, 'Ongoing')
        else
          @project.update_attribute(:status, 'Quote')
        end
        # Send email notification about the modification of the status
        ExampleMailer.status(@project).deliver
      end
    end
    @output_file.destroy
    respond_to do |format|
      format.html { redirect_to @project, notice: 'Delivery was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Download the file
  def download
    path = "#{@output_file.file_path}"
    send_file path, :x_sendfile=>true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_output_file
      @output_file = OutputFile.find(params[:id])
    end

    # Set the project of the file
    def set_project
      @project = Project.find(params[:project_id])
    end

    # Set the project of the file to download
    def set_project_download
      @project = Project.find(@output_file.project_id)
    end

    # Check if the current user belongs to a company or if they are an administrator or a project manager.
    def check_company
      if current_user.company == nil && !current_user.manager? && !current_user.admin?
        redirect_to new_company_path, :alert => "You have to create or be invited by a company before access to the website." and return
      end
    end

    # Check if the current user has the right to see and download the deliveries of the current project.
    def check_auth
      if @project.project_owner_id != current_user.id && !current_user.admin? && current_user.id != @project.project_manager_id && !(current_user.company == @project.project_owner.company && current_user.company_admin?)
        redirect_to projects_path, :alert => "Access denied." and return
      end
    end

    # Check if the current user has the right to add / destroy the deliveries of the current project.
    def check_auth_admin
      if !current_user.admin? && current_user.id != @project.project_manager_id
        redirect_to projects_path, :alert => "Access denied." and return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def output_file_params
      params.require(:output_file).permit(:file_path, :project_id, :name)
    end
end

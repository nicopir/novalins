class InputFilesController < ApplicationController
  before_action :set_input_file, only: [:update, :destroy, :download]
  before_action :set_project, only: [:index, :new, :edit, :create, :update, :destroy]
  before_action :set_project_download, only: [:download]
  before_action :check_company
  before_action :check_auth

  # GET /input_files
  # GET /input_files.json
  def index
    @input_files = @project.input_files
  end

  # GET /input_files/new
  def new
    @input_file = InputFile.new
  end

  # POST /input_files
  # POST /input_files.json
  def create
    @input_file = InputFile.new(input_file_params)
    respond_to do |format|
      if @input_file.save
        @input_file.update_attribute(:project_id, @project.id)
        # Send email notification to Admins and PM of the project
        ExampleMailer.new_input_file(@project).deliver
        format.html { redirect_to @project, notice: 'Client file was successfully created.' }
        format.json { render :show, status: :created, location: @input_file }
      else
        format.html { render :new }
        format.json { render json: @input_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /input_files/1
  # DELETE /input_files/1.json
  def destroy
    @input_file.destroy
    respond_to do |format|
      format.html { redirect_to @project, notice: 'Client file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Download the file
  def download
    path = "#{@input_file.file_path}"
    send_file path, :x_sendfile=>true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_input_file
      @input_file = InputFile.find(params[:id])
    end

    # Set the project of the file
    def set_project
      @project = Project.find(params[:project_id])
    end

    # Set the project of the file to download
    def set_project_download
      @project = Project.find(@input_file.project_id)
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
    def input_file_params
      params.require(:input_file).permit(:name, :file_path, :project_id)
    end
end

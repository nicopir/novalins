class ProjectsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_project, only: [:show, :edit, :update, :destroy, :accept, :reject, :manage, :download]
  before_action :check_company
  before_action :check_auth, only: [:show, :update, :destroy, :accept, :reject]
  

  # GET /projects
  # GET /projects.json
  def index
    # Get the projects to display according to the role of the user
    if current_user.admin?
      @projects = Project.all
      print 'ADMIn PROJECT '+@projects.to_s
    elsif current_user.manager?
      @projects = Project.where('project_manager_id=? OR project_owner_id=?', current_user.id, current_user.id)
    elsif current_user.company_admin?
      @projects = current_user.company.project_owned
    else
      @projects = current_user.project_owned
    end
    # Search and then sort
    if params[:search]
      @projects = @projects.search(params[:search]).order(sort_column + ' ' + sort_direction)
    end
    # Sort the projects
    @projects = @projects.order(sort_column + ' ' + sort_direction)
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
    # Can not edit the project when the status is Delivered or Closed if the user is not admin or PM of the project
    if (@project.status == "Delivered" || @project.status == "Closed") && !current_user.admin? && !(current_user.manager? && current_user.id == @project.project_manager_id)
      redirect_to projects_path, :alert => "The project is closed, you can't edit it." and return
    end
  end

  # Set advanced attributes for the project
  def manage
    # Can not manage the project if the user is not admin or PM of the project
    if !current_user.admin? && !(current_user.manager? && current_user.id == @project.project_manager_id)
      redirect_to projects_path, :alert => "You can not manage this project." and return
    end
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)
    respond_to do |format|
      if @project.save
        @project.update_attribute(:status, 'Pending')
        @project.update_attribute(:project_owner_id, current_user.id)
        @project.update_attribute(:company_id, current_user.company_id)
        # Send mail notification to the admins and to the current user about the creation of the project
        ExampleMailer.create_project_admin(@project).deliver
        ExampleMailer.create_project(@project).deliver
        format.html { redirect_to new_project_input_file_path(@project), notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    # Update of the management form
    if params[:save]
      respond_to do |format|
        manager = @project.project_manager_id
        if @project.update(project_params)
          if manager != @project.project_manager_id
            # Notify the new manager by email
            ExampleMailer.new_manager(@project).deliver
          end
          # Notify the owner of the project about the management of its project
          ExampleMailer.manage(@project).deliver
          format.html { redirect_to @project, notice: 'Project was successfully managed.' }
          format.json { render :show, status: :ok, location: @project }
        else
          format.html { render :manage }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    # Update of the regular form
    else
      respond_to do |format|
        if @project.update(project_params)
          format.html { redirect_to @project, notice: 'Project was successfully updated.' }
          format.json { render :show, status: :ok, location: @project }
        else
          format.html { render :edit }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def accept
    # Check if the user is authorized to accept the project
    if @project.status != 'Quote' || (current_user != @project.project_owner && !(current_user.company_admin? && current_user.company_id == @project.company_id))
      redirect_to projects_path, :alert => "Access denied." and return
    end
    # Set the attributes of the project with the values of the last quotation
    @quotation = @project.quotations.last
    @project.update_attribute(:cost, @quotation.cost)
    @project.update_attribute(:currency_id, @quotation.currency_id)
    @project.update_attribute(:deadline, @quotation.deadline)
    @project.update_attribute(:confirmation, true)
    @project.update_attribute(:status, 'Ongoing')
    @project.update_attribute(:starting, Date.today)
    # Notify the admins and the PM that the project is accepted
    ExampleMailer.accept_project_admin(@project).deliver
    redirect_to @project and return
  end

  def reject
    # Check if the user is authorized to reject the project
    if @project.status != 'Ongoing' || (current_user != @project.project_owner && !(current_user.company_admin? && current_user.company_id == @project.company_id))
      redirect_to projects_path, :alert => "Access denied." and return
    end
    # Reset the attributes of the project with default values
    @project.update_attribute(:cost, nil)
    @project.update_attribute(:deadline, nil)
    @project.update_attribute(:confirmation, false)
    @project.update_attribute(:status, 'Quote')
    @project.update_attribute(:starting, Date.today)
    # Notify the admins and the PM that the project is rejected
    ExampleMailer.reject_project_admin(@project).deliver
    redirect_to @project and return
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    def check_company
      # Check if the user is invited in a new company
      invit = Invitation.all.where(email: current_user.email).where(done: false)
      if invit.size != 0
        current_user.update_attribute(:company_id, invit.first.company_id)
        invit.first.update_attribute(:done, true)
      end
      # Check if the current user belongs to a company or if they are an administrator or a project manager.
      if current_user.company == nil && !current_user.manager? && !current_user.admin?
        redirect_to new_company_path, :alert => "You have to create or be invited by a company before access to the website." and return
      end
    end

    # Check if the current user has the rights to see, edit, update, accept, reject or destroy a project.
    def check_auth
      if @project.project_owner_id != current_user.id && !current_user.admin? && current_user.id != @project.project_manager_id && !(current_user.company == @project.project_owner.company && current_user.company_admin?)
        redirect_to projects_path, :alert => "Access denied." and return
      end
    end

    # Sort column
    def sort_column  
      Project.column_names.include?(params[:sort]) ? params[:sort] : "created_at"  
    end   
    
    # Sort direction
    def sort_direction  
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"  
    end  

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:title, :status, :description, :cost, :instruction, :category_id, :urgency, :deadline, :starting, :project_manager_id, :currency_id)
    end
end

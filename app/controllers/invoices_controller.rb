class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:destroy, :update, :download]
  before_action :set_project, only: [:index, :new, :edit, :create, :update, :destroy]
  before_action :set_project_download, only: [:download]
  before_action :check_company
  before_action :check_auth_admin, only: [:new, :create, :destroy]
  before_action :check_auth, only: [:index, :download]

  # GET /invoices
  # GET /invoices.json
  def index
    @invoices = @project.invoices
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new
  end

  # POST /invoices
  # POST /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)
    respond_to do |format|
      if @invoice.save
        @invoice.update_attribute(:project_id, @project.id)
        # Close the project
        if @project.status != 'Closed'
          @project.update_attribute(:status, 'Closed')
          # Send email notification about the modification of the status
          ExampleMailer.status(@project).deliver
        end
        # Send email notification to the owner of the project
        ExampleMailer.new_invoice(@project).deliver
        format.html { redirect_to @project, notice: 'Invoice was successfully created.' }
        format.json { render :show, status: :created, location: @invoice }
      else
        format.html { render :new }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.json
  def destroy
    # Check the new status if there is no invoice anymore
    if @project.invoices.size == 1
      if @project.output_files.size == 0 
        if @project.quotations.size == 0
          @project.update_attribute(:status, 'Pending')
        elsif @project.confirmation?
          @project.update_attribute(:status, 'Ongoing')
        else
          @project.update_attribute(:status, 'Quote')
        end
      else
        @project.update_attribute(:status, 'Closed')
      end
      # Send email notification about the modification of the status
      ExampleMailer.status(@project).deliver
    end
    @invoice.destroy
    respond_to do |format|
      format.html { redirect_to @project, notice: 'Invoice was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Download the file
  def download
    path = "#{@invoice.file_path}"
    send_file path, :x_sendfile=>true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    # Set the project of the file
    def set_project
      @project = Project.find(params[:project_id])
    end

    # Set the project of the file to download
    def set_project_download
      @project = Project.find(@invoice.project_id)
    end

    # Check if the current user belongs to a company or if they are an administrator or a project manager.
    def check_company
      if current_user.company == nil && !current_user.manager? && !current_user.admin?
        redirect_to new_company_path, :alert => "You have to create or be invited by a company before access to the website." and return
      end
    end

    # Check if the current user has the right to see and download the invoices of the current project.
    def check_auth
      if @project.project_owner_id != current_user.id && !current_user.admin? && current_user.id != @project.project_manager_id && !(current_user.company == @project.project_owner.company && current_user.company_admin?)
        redirect_to projects_path, :alert => "Access denied." and return
      end
    end

    # Check if the current user has the right to add / destroy the invoices of the current project.
    def check_auth_admin
      if !current_user.admin? && current_user.id != @project.project_manager_id
        redirect_to projects_path, :alert => "Access denied." and return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invoice_params
      params.require(:invoice).permit(:file_path, :project_id, :name)
    end
end

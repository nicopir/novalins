class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy, :leave]
  before_action :check_auth, only: [:show, :edit, :update, :destroy, :leave]

  # GET /companies
  # GET /companies.json
  def index
    # Available only for admin and project manager
    if current_user.admin? || current_user.manager?
      @companies = Company.all
    else
      redirect_to projects_path, :alert => "Access denied." and return
    end
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(company_params)
    respond_to do |format|
      if @company.save
        # User becomes company admin
        current_user.update_attribute(:company_id, @company.id)
        current_user.update_attribute(:company_admin, true)
        # Send email notifications to Admins and current user
        ExampleMailer.create_company_admin(@company).deliver
        ExampleMailer.create_company(@company).deliver
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    # Admin only
    if !current_user.admin?
      redirect_to projects_path, :alert => "Access denied." and return
    end
    # Set to false the value of the company_admin
    @admins = User.all.where(company_admin: true).where(company_id: @company.id)
    @admins.each do |admin|
      admin.update_attribute(:company_admin, false)
    end
    # Delete the company attribute of the company's members
    @users = @company.users
    @users.each do |user|
      user.update_attribute(:company_id, nil)
    end
    # Delete the company
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # User leaves the company
  def leave
    if current_user.company == @company
      current_user.update_attribute(:company_id, nil)
      current_user.update_attribute(:company_admin, false)
      redirect_to projects_path and return
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Check if the current user belongs to this company or if they are an administrator or a project manager.
    def check_auth
      if current_user.company_id != @company.id && !current_user.manager? && !current_user.admin?
        redirect_to projects_path, :alert => "Access denied." and return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:name, :description, :website, :logo, :billing_name, :vat_number, :street, :city, :state, :postal_code, :country)
    end
end

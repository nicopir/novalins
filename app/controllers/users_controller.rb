class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :grantManager, :removeManagerPriv, :destroy]
  before_action :check_auth

  def show
  end

  def index
    # Index only available for admins and project managers
    if !current_user.admin? && !current_user.manager?
      redirect_to projects_path, :alert => "Access denied." and return
    end
    @users = User.all
  end

  def edit
    if current_user != @user
      redirect_to projects_path, :alert => "Access denied." and return
    end
  end

  def grantManager
    # Check if the current user is authorized to promote
    if !current_user.admin?
      redirect_to "/projects", :alert => "Access denied." and return
    end
    # Check if the user can be promoted
    if @user.admin?
      redirect_to "/users", :alert => "The user is already an administrator." and return
    end
    if @user.manager?
      redirect_to "/users", :alert => "The user is already a manager." and return
    end
    # Set the boolean project manager to true
    @user.update_attribute(:manager, true)
    # Notify the new project manager about the promotion
    ExampleMailer.grant_manager(@user).deliver
    redirect_to @user, notice: (@user.lastname+" "+@user.firstname+" is now a manager.") and return
  end

  def removeManagerPriv
    # Check if the current user is authorized to cancel the promotion
    if !current_user.admin?
      redirect_to "/projects", :alert => "Access denied." and return
    end
    if !@user.manager?
      redirect_to "/users", :alert => "The user is not a manager." and return
    end
    if @user.admin?
      redirect_to "/users", :alert => "The user is an administrator." and return
    end
    # Set the boolean project manager to false
    @user.update_attribute(:manager, false)
    redirect_to @user, notice: (@user.lastname+" "+@user.firstname+" is not a manager anymore.") and return
  end

  def destroy
    # Check if the current user is an admin
    if !current_user.admin?
      redirect_to "/users", :alert => "Access denied." and return
    end
    # Check if the user selected is not an admin
    if @user.admin?
      redirect_to "/users", :alert => "You can not delete an administrator." and return
    end
    # Destroy the user
    @user.destroy
    if @user.destroy
      redirect_to root_url, notice: "User deleted." and return
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    # Check if the current user is authorized to access to the data of the user
    def check_auth
      if current_user != @user && !current_user.manager? && !current_user.admin?
        redirect_to projects_path, :alert => "Access denied." and return
      end
    end

    def sign_up_params
      params.require(:user).permit(:firstname, :lastname, :department, :mobile, :contact_person, :address, :location, :phone, :email, :password, :password_confirmation)
    end

    def account_update_params
      params.require(:user).permit(:firstname, :lastname, :department, :mobile, :contact_person, :address, :location, :phone, :email, :password, :password_confirmation, :current_password)
    end
end

class RegistrationsController < Devise::RegistrationsController

  def create
    super
    # Check if the new user is already invited in a new company
    invit = Invitation.all.where(email: resource.email)
    if invit.size != 0
      resource.update_attribute(:company_id, invit.first.company_id)
    end
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  def sign_up_params
    params.require(:user).permit(:firstname, :lastname, :department, :mobile, :contact_person, :address, :location, :phone, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:firstname, :lastname, :department, :mobile, :contact_person, :address, :location, :phone, :email, :password, :password_confirmation, :current_password)
  end
end

class InvitationsController < ApplicationController
  before_action :set_company
  before_action :check_admin

  # GET /invitations/new
  def new
    @invitation = Invitation.new
  end

  # POST /invitations
  # POST /invitations.json
  def create
    @invitation = Invitation.new(invitation_params)
    respond_to do |format|
      if @invitation.save
        @invitation.update_attribute(:company_id, @company.id)
        # Send email notification
        ExampleMailer.new_invitation(@invitation).deliver
        format.html { redirect_to root_path, notice: 'Invitation was successfully created.' }
        format.json { render :new, status: :created, location: @invitation }
      else
        format.html { render :new }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_company
      @company = Company.find(params[:id])
    end

    # Check if the current user is an admin or the admin of the company
    def check_admin
      if !(current_user.company_admin? && current_user.company == @company) && !current_user.admin?
        redirect_to projects_path, :alert => "You can not invite people to this company." and return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invitation_params
      params.require(:invitation).permit(:company_id, :email)
    end
end

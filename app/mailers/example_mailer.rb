class ExampleMailer < ActionMailer::Base
  default from: "notifications@portal-novalins.com"

  ######### Emails about user #########

  # Notify the project manager that he is in charge of a new project
  def new_manager(project)
    @project = project
    mail(to: @project.project_manager.email, subject: 'Your are now manager of a new project')
  end

  # Notify the user that he has been promoted as Project Manager
  def grant_manager(user)
    @user = user
    mail(to: @user.email, subject: 'Your have been promoted as Project Manager')
  end

  # Notify the user that he has been invited in a new company
  def new_invitation(invitation)
    @comp = Company.find(invitation.company_id)
    subj = 'You are invited to join the company '+@comp.name+' on Novalins'
    mail(to: invitation.email, subject: subj)
  end

  # Notify the user about the reception of a new message
  def new_message(message)
    @message = message
    mail(to: @message.receiver.email, subject: 'You have received a new message')
  end

  ######### Emails about company #########

  # Notify the user about the creation of his company
  def create_company(company)
    @company = company
    @user = User.all.where(company_id: @company.id).where(company_admin: true).first
    mail(to: @user.email, subject: 'Your company has been successfully created')
  end

  # Notify the admins about the creation of the new company
  def create_company_admin(company)
    @company = company
    adminList = User.where(admin: true)
    @company_admin = User.all.where(company_id: @company.id).where(company_admin: true).first
    for admin in adminList
      @user = admin
      mail(to: @user.email, subject: 'New company created')
    end
  end

  ######### Emails about project #########

  # Notify the user about the creation of his project
  def create_project(project)
    @project = project
    mail(to: @project.project_owner.email, subject: 'Your project has been successfully created')
  end

  # Notify the admins about the creation of the new project 
  def create_project_admin(project)
    @project = project
    adminList = User.where(admin: true)
    for admin in adminList
      @user = admin
      mail(to: admin.email, subject: 'New project created')
    end
  end

  # Notify the user about the modification of the status of his project
  def status(project)
    @project = project
    mail(to: @project.project_owner.email, subject: 'The status of your project has changed')
  end

  # Notify the user about the management of his project by the project manager
  def manage(project)
    @project = project
    mail(to: @project.project_owner.email, subject: 'Your project has been managed')
  end

  # Notify the admins and the project manager that a project has been accepted by the client
  def accept_project_admin(project)
  	@project = project
    adminList = User.where(admin: true)
    if @project.project_manager != nil
      adminList << @project.project_manager
    end
    for admin in adminList
    	@user = admin
    	mail(to: admin.email, subject: 'Project approuved')
    end
  end

  # Notify the admins and the project manager that a project has been rejected by the client
  def reject_project_admin(project)
  	@project = project
    adminList = User.where(admin: true)
    if @project.project_manager != nil
      adminList << @project.project_manager
    end
    for admin in adminList
    	@user = admin
    	mail(to: admin.email, subject: 'Project rejected')
    end
  end

  # Notify the admins and the project manager that a client file has been uploaded
  def new_input_file(project)
    @project = project
    adminList = User.where(admin: true)
    if @project.project_manager != nil
      adminList << @project.project_manager
    end
    for admin in adminList
      @user = admin
      mail(to: admin.email, subject: 'New client file')
    end
  end

  # Notify the client that a quotation has been uploaded for his project
  def new_quotation(project)
    @project = project
    mail(to: @project.project_owner.email, subject: 'A new quotation has been uploaded')
  end

  # Notify the client that a invoice has been uploaded for his project
  def new_invoice(project)
    @project = project
    mail(to: @project.project_owner.email, subject: 'A new invoice has been uploaded')
  end

  # Notify the client that a delivery has been uploaded for his project
  def new_output_file(project)
    @project = project
    mail(to: @project.project_owner.email, subject: 'A new delivery has been uploaded')
  end
end
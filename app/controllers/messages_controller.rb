class MessagesController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_message, only: [:show, :edit, :update, :destroy]
  before_action :check_company
  before_action :check_auth, only: [:edit, :update, :destroy]

  # GET /messages
  # GET /messages.json
  def index
    # Get the messages
    @messages_sent = current_user.message_sent
    @messages_received = current_user.message_received
    # Sort the messages
    @messages_sent = @messages_sent.order(sort_column + ' ' + sort_direction)
    @messages_received = @messages_received.order(sort_column + ' ' + sort_direction)
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    # Check if the user is the sender or the receiver
    if current_user != @message.receiver && current_user != @message.sender
      redirect_to projects_path, :alert => "Access denied." and return
    end
    # Set the boolean read to true when the receiver open the message for the first time
    if current_user == @message.receiver && @message.read == false
      @message.update_attribute(:read, true)
    end
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(message_params)
    # Check if a project has been selected
    if message_params[:project_id] == nil
      redirect_to new_message_path, :alert => "You have to select a project" and return
    end
    # Check if the project selected has a project manager
    @project = Project.find(message_params[:project_id])
    if @project.project_manager_id == nil
      redirect_to @message.project, :alert => "There is no project manager associated to this project." and return
    end
    respond_to do |format|
      if @message.save
        @message.update_attribute(:sender_id, current_user.id)
        # Set the receiver of the message according the role of the user
        if current_user != @message.project.project_manager
          @message.update_attribute(:receiver_id, @message.project.project_manager.id)
        else
          @message.update_attribute(:receiver_id, @message.project.project_owner.id)
        end
        # Send email notification to the receiver of the message
        ExampleMailer.new_message(@message).deliver
        format.html { redirect_to @message, notice: 'Message was successfully created.' }
        format.json { render :show, status: :created, location: @message }
      else
        format.html { render :new }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        if current_user != @message.project.project_manager
          @message.update_attribute(:receiver_id, @message.project.project_manager.id)
        else
          @message.update_attribute(:receiver_id, @message.project.project_owner.id)
        end
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to messages_url, notice: 'Message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # CHeck if the user is the sender of the message
    def check_auth
      if current_user != @message.sender
        redirect_to projects_path, :alert => "Access denied." and return
      end
    end

    # Check if the current user belongs to a company or if they are an administrator or a project manager.
    def check_company
      if current_user.company == nil && !current_user.manager? && !current_user.admin?
        redirect_to new_company_path, :alert => "You have to create or be invited by a company before access to the website." and return
      end
    end

    # Sort column
    def sort_column
      Message.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end   
      
    # Sort direction
    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "desc"  
    end 

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:subject, :body, :read, :project_id, :sender_id, :receiver_id)
    end
end

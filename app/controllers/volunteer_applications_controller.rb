class VolunteerApplicationsController < ApplicationController
  before_action :create_volunteer_application, :create_conversation, only: [:create]
  def new
    @project = Project.find(params[:project_id])
    @message = Message.new(project_id: params[:project_id], 
    recipient_id: @project.project_admin.id, subject: "Project Request: #{@project.title}")
  end

  def create
    sends_application_and_conversation_to_admin(@volunteer_application, @conversation1_about_volunteer_application)
    if current_user.can_follow?(@organization_administrator)
      current_user.follow!(@organization_administrator) && @organization_administrator.follow!(current_user)
    end
  end

private

  def message_params
    params.require(:message).permit(:subject, :sender_id, :recipient_id, :body)
  end

  def create_volunteer_application
    @volunteer_application = VolunteerApplication.create(administrator_id: message_params[:recipient_id], applicant_id: current_user.id, project_id: params[:project_id])
  end

  def create_conversation
    @conversation1_about_volunteer_application = Conversation.create
  end

  def sends_application_and_conversation_to_admin(application, conversation)
    @message = Message.create(message_params)
    @message.update_columns(conversation_id: conversation.id)
    @organization_administrator = User.find(@message.recipient_id)
    conversation.update_columns(volunteer_application_id: application.id)
    flash[:success] = "Your message has been sent to #{@message.recipient.first_name} #{@message.recipient.last_name}"
    redirect_to conversations_path
  end
end
class ContractsController < ApplicationController
  before_action :find_volunteer_application, only: [:create]
  def new
    contract = Contract.find(params[:contract_id])
    @project = Project.find(contract.project_id)
    @message = Message.new(recipient_id: @project.project_admin.id, subject: "Please Review Work: #{@project.title}")
  end

  def create
    accept_application_and_project_in_production(@volunteer_application)
    reject_other_applications_and_clear_conversations_of_application_id(@volunteer_application)
    create_contract_and_associate_it_with_conversation_which_triggers_drop_opportunity(@volunteer_application)
  end

  def destroy 
    send_automated_message
    contract_drops_and_project_becomes_open(@contract)
  end

  def update
    find_conversation_and_update_contract_associated_with_it
  end

private

  def message_params
    params.require(:message).permit(:subject, :sender_id, :recipient_id, :body)
  end

  def find_volunteer_application
    @volunteer_application = VolunteerApplication.find(params[:volunteer_application_id])
  end

  def accept_application_and_project_in_production(application)
    application.update_columns(accepted: true, rejected: false)
    project = Project.find(application.project_id)
    project.update_columns(state: nil)
  end

  def reject_other_applications_and_clear_conversations_of_application_id(application)
    rejected_applications = VolunteerApplication.where(accepted: nil, rejected: nil, 
      project_id: application.project_id).to_a
    rejected_applications.each do |member|
      member.update!(accepted: false, rejected: true)
      rejected_conversations = Conversation.where(volunteer_application_id: member.id).to_a
      rejected_conversations.map do |member|
        member.update!(volunteer_application_id: nil)
      end
    end
  end

  def create_contract_and_associate_it_with_conversation_which_triggers_drop_opportunity(accepted_application)
    @conversation = Conversation.find(params[:conversation_id])
    volunteer = User.find(accepted_application.applicant_id)
    @contract = Contract.create(active: true, contractor_id: current_user.id,
     volunteer_id: volunteer.id, project_id: accepted_application.project_id, work_submitted: false)
    @conversation.update!(contract_id: @contract.id, volunteer_application_id: nil)
    redirect_to conversation_path(@conversation.id)
  end

  def send_automated_message
    @contract = Contract.find(params[:id])
    @conversation = Conversation.find_by(contract_id: @contract.id)
    first_message = @conversation.messages.first
    @conversation.messages << Message.create(subject: first_message.subject, body: "Automated Message: #{first_message.sender.first_name} #{first_message.sender.last_name} has been dropped on this project. This is an automated message." )
  end

  def contract_drops_and_project_becomes_open(contract)
    @contract.update!(volunteer_id: nil, dropped_out: true, active: false)
    project = Project.find(contract.project_id)
    project.update_columns(state: "open")
    redirect_to conversation_path(@conversation.id)
  end

  def find_conversation_and_update_contract_associated_with_it
    contract = Contract.find(params[:id])
    complete_work_conversation = Conversation.find_by(contract_id: contract.id)
    contract.update_columns(complete: true, active: false, incomplete: false, work_submitted: true )
    redirect_to conversation_path(complete_work_conversation.id)
  end
end
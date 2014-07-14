class WorkSubmissionsController < ApplicationController
  def new
    @contract = Contract.find(params[:contract_id])
    @project = Project.find(@contract.project_id)
    @message = Message.new(recipient_id: @contract.contractor_id, subject: "Work Submission for #{@project.title}")
  end

  def create
    creates_new_conversation_about_work_submission_and_updates_contract
    opportunity_to_drop_project_is_removed(@contract, @first_message)
  end

private

  def message_params
    params.require(:message).permit(:subject, :sender_id, :recipient_id, :body)
  end

  def creates_new_conversation_about_work_submission_and_updates_contract
    conversation_about_work_submission = Conversation.create
    @first_message = Message.new(message_params.merge!(conversation_id: conversation_about_work_submission.id))
    @first_message.save
    @contract = Contract.find(params[:id])
    conversation_about_work_submission.update_columns(contract_id: @contract.id)
    @contract.update_columns(work_submitted: true, complete: nil, active: true)
  end


  def opportunity_to_drop_project_is_removed(contract, first_message)
    previous_conversation_loses_drop_opportunity = Conversation.where(contract_id: contract.id).first
    previous_conversation_loses_drop_opportunity.update_columns(contract_id: nil)
    flash[:success] = "Your message has been sent to #{first_message.recipient.first_name} #{first_message.recipient.last_name}"
    redirect_to conversations_path
  end  
end
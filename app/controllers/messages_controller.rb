class MessagesController < ApplicationController
  before_filter :current_user
  def new
    @user = User.find(params[:user_id])
    @message = Message.new(recipient_id: @user.id)
    
  end

  def create
    if user_creating_a_reply?
      handles_replies
    else
      handles_first_message
    end
  end

  def index
    @messages = current_user.only_conversations
  end

  def outgoing_messages
    @messages = current_user.sent_messages
  end

private
  

  def user_creating_a_reply?
    params[:message][:conversation_id]
  end

  def message_params
    params.require(:message).permit(:subject, :sender_id, :recipient_id, :body)
  end

  def handles_replies
    @message = Message.new(message_params.merge!(conversation_id: params[:message][:conversation_id]))
    @message.save
    redirect_to conversations_path
    flash[:success] = "Your message has been sent to #{@message.recipient.first_name} #{@message.recipient.last_name}"
  end

  def handles_first_message
    conversation = Conversation.create 
    @message = Message.new(message_params.merge!(conversation_id: conversation.id))
    @message.save
    redirect_to conversations_path
  end
end
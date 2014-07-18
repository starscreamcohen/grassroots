class Conversation < ActiveRecord::Base
  has_many :messages, -> {order('created_at ASC')}#, dependent: :destroy
  #has many users

  def sender_user_name_of_recent_message
    message = self.messages.last 
    user = message.sender_id
    name = User.find_by(id: user)
    if name
      "#{name.first_name} #{name.last_name}"
    end
  end

  def the_id_of_sender
    message = self.messages.last
    user = message.sender_id
    name = User.find_by(id: user)
    if name
      name.id
    end
  end

  def message_subject
    message = self.messages.last
    message_subject = message.subject
  end

  def message_body
    message = self.messages.last
    message_body = message.body
  end

  def join_request
    message = self.messages.first
    project = Project.find_by(id: message.project_id)
    if project
      if project.users.count >= 2
        project.state == "open"
      end
    end
  end

  def with_work_submitted
    contract = Contract.find(self.contract_id)
    contract.active && contract.work_submitted
  end

  def with_opportunity_to_drop_job
    contract = Contract.find(self.contract_id)
    contract.active && contract.work_submitted == false && contract.created_at > 5.days.ago
  end
end
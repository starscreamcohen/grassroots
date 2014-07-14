class WorkConversationsController < ApplicationController
  def index
    @work = current_user.only_conversations_about_work
  end
end
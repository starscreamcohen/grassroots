class StatusUpdatesController < ApplicationController
  before_action :authorize, only: [:create]

  def create
    @status_update = StatusUpdate.create(status_params.merge!(user_id: current_user.id))
    @newsfeed_item = NewsfeedItem.create(user_id: current_user.id)
    @status_update.newsfeed_items << @newsfeed_item
    redirect_to :back
  end

private

  def status_params
    params.require(:status_update).permit(:content, :user_id)
  end
end
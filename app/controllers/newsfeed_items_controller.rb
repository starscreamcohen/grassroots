class NewsfeedItemsController < ApplicationController
  def index
    @status_update = StatusUpdate.new
    @relevent_activity = NewsfeedItem.from_users_followed_by(current_user).sort_by(&:created_at).reverse
    @comment = Comment.new
  end
end
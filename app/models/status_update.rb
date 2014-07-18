class StatusUpdate < ActiveRecord::Base
  belongs_to :author, foreign_key: 'user_id', class_name: 'User'
  has_many :newsfeed_items, as: :newsfeedable
  #has_many :comments, as: :commentable
  #has_many :votes, as: :voteable
end
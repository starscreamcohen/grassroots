class Answer < ActiveRecord::Base
  include Voteable
  belongs_to :author, foreign_key: 'user_id', class_name: 'User'
  belongs_to :question
  has_many :comments, as: :commentable
  has_many :newsfeed_items, as: :newsfeedable

  validates_presence_of :description
  
end
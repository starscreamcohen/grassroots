class Question < ActiveRecord::Base
  include Voteable
  belongs_to :author, foreign_key: 'user_id', class_name: 'User'
  has_many :answers
  has_many :comments, as: :commentable
  has_many :categorizations
  has_many :categories, through: :categorizations
  
  has_many :newsfeed_items, as: :newsfeedable
  has_many :comments, as: :commentable

  validates_presence_of :title, :description

end
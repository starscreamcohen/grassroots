class Comment < ActiveRecord::Base
  include Voteable
  belongs_to :author, foreign_key: 'user_id', class_name: 'User'
  belongs_to :commentable, polymorphic: :true
  

  validates_presence_of :content

end
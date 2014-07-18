class Badge < ActiveRecord::Base
  has_many :accomplishments
  has_many :users, through: :accomplishments
  has_many :newsfeed_items, as: :newsfeedable
end
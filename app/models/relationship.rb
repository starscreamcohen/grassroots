class Relationship < ActiveRecord::Base
  belongs_to :follower, class_name: 'User'
  belongs_to :leader, class_name: 'User'
  has_many :newsfeed_items, as: :newsfeedable

  def leader_organization_name
    leader.organization.name
  end
end
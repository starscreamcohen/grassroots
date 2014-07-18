require 'spec_helper'

describe Relationship do
  it { should have_many(:newsfeed_items)}
  it { should belong_to(:follower)}
  it { should belong_to(:leader)}

  describe "#leader_organization_name" do
    it "shows the leader's organization name" do
      alice = Fabricate(:user, user_group: "nonprofit")
      huggey_bear = Fabricate(:organization)
      bob = Fabricate(:user, user_group: "nonprofit", organization_id: huggey_bear.id)
      alice.follow!(bob)
      first_relationship = Relationship.first

      expect(first_relationship.leader_organization_name).to eq(huggey_bear.name)
    end
  end
end
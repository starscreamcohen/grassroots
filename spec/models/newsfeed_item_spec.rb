require 'spec_helper'

describe NewsfeedItem do
  it {should belong_to(:author)}

  let!(:huggey_bears) {Fabricate(:organization, cause: "animals")}
  let!(:global) {Fabricate(:organization, cause: "social good")}
  let!(:alice) {Fabricate(:organization_administrator, first_name: "Alice", organization_id: huggey_bears.id, user_group: "nonprofit")}
  let!(:bob) {Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
  let!(:cat) {Fabricate(:organization_administrator, first_name: "Cat", organization_id: global.id, user_group: "nonprofit")}

  it "returns an array of newsfeed items for the user from the user's following" do
    Fabricate(:relationship, follower_id: bob.id, leader_id: alice.id )
    graphic_design = Fabricate(:project, title: "graphic design", organization_id: huggey_bears.id)
    newsfeed_item = NewsfeedItem.create(user_id: alice.id)
    graphic_design.newsfeed_items << newsfeed_item

    wordpress = Fabricate(:project, title: "word press", organization_id: huggey_bears.id)
    newsfeed_item2 = NewsfeedItem.create(user_id: alice.id)
    wordpress.newsfeed_items << newsfeed_item2

    expect(NewsfeedItem.from_users_followed_by(bob)).to match_array([newsfeed_item, newsfeed_item2])
  end

  it "returns an array of newsfeed items from the user's following in the order that they were created" do
    Fabricate(:relationship, follower_id: bob.id, leader_id: alice.id)

    accounting = Fabricate(:project, title: "accounting", organization_id: huggey_bears.id, created_at: 5.days.ago)
    newsfeed_item3 = NewsfeedItem.create(user_id: alice.id)
    accounting.newsfeed_items << newsfeed_item3

    graphic_design = Fabricate(:project, title: "graphic design", organization_id: huggey_bears.id, created_at: 1.month.ago)
    newsfeed_item = NewsfeedItem.create(user_id: alice.id)
    graphic_design.newsfeed_items << newsfeed_item

    wordpress = Fabricate(:project, title: "word press", organization_id: huggey_bears.id, created_at: 2.weeks.ago)
    newsfeed_item2 = NewsfeedItem.create(user_id: alice.id)
    wordpress.newsfeed_items << newsfeed_item2


    expect(NewsfeedItem.from_users_followed_by(bob)).to match_array([newsfeed_item, newsfeed_item2, newsfeed_item3])
  end

  it "does not include in the array of newsfeed items items that are not part of the users following" do
    Fabricate(:relationship, follower_id: bob.id, leader_id: alice.id)

    accounting = Fabricate(:project, title: "accounting", organization_id: huggey_bears.id, created_at: 5.days.ago)
    newsfeed_item3 = NewsfeedItem.create(user_id: alice.id)
    accounting.newsfeed_items << newsfeed_item3

    graphic_design = Fabricate(:project, title: "graphic design", organization_id: huggey_bears.id, created_at: 1.month.ago)
    newsfeed_item = NewsfeedItem.create(user_id: alice.id)
    graphic_design.newsfeed_items << newsfeed_item

    wordpress = Fabricate(:project, title: "word press", organization_id: huggey_bears.id, created_at: 2.weeks.ago)
    newsfeed_item2 = NewsfeedItem.create(user_id: alice.id)
    wordpress.newsfeed_items << newsfeed_item2

    business = Fabricate(:project, title: "Business development", organization_id: global.id, created_at: 3.weeks.ago)
    newsfeed_item4 = NewsfeedItem.create(user_id: cat.id)
    business.newsfeed_items << newsfeed_item4

    expect(NewsfeedItem.from_users_followed_by(bob).count).to eq(3)
  end

  it "shows the users own newsfeed items" do
    status_update1 = Fabricate(:status_update, content: "I had a great day today")
    newsfeed_item = NewsfeedItem.create(user_id: alice.id)
    status_update1.newsfeed_items << newsfeed_item

    accounting = Fabricate(:project, title: "accounting", organization_id: huggey_bears.id, created_at: 5.days.ago)
    newsfeed_item2 = NewsfeedItem.create(user_id: alice.id)
    accounting.newsfeed_items << newsfeed_item2
    expect(NewsfeedItem.from_users_followed_by(alice)).to eq([newsfeed_item, newsfeed_item2])
  end
end
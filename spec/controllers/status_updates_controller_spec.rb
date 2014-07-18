require 'spec_helper'

describe StatusUpdatesController, :type => :controller do
  describe "POST create" do

    let!(:huggey_bears) {Fabricate(:organization, cause: "animals")}
    let!(:alice) {Fabricate(:organization_administrator, first_name: "Alice", organization_id: huggey_bears.id, user_group: "nonprofit")}
    let!(:bob) {Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
    let!(:cat) {Fabricate(:user, first_name: "Cat", user_group: "volunteer")}

    before(:each) do
      request.env["HTTP_REFERER"] = "/newsfeed_items" unless request.nil? or request.env.nil?
    end

    it "redirects to sign in path if user not signed in" do
      post :create, status_update: {content: "I had a great day today"}

      expect(response).to redirect_to(sign_in_path)
    end

    it "redirects the user back to where he/she posted an update" do
      set_current_user(alice)
      post :create, status_update: {content: "I had a great day today"}

      expect(response).to redirect_to(newsfeed_items_path)
    end

    it "creates an update" do
      set_current_user(alice)
      post :create, status_update: {content: "I had a great day today"}

      expect(StatusUpdate.count).to eq(1)
    end

    it "associates the update with a user" do
      set_current_user(alice)
      post :create, status_update: {content: "I had a great day today"}

      expect(StatusUpdate.first.author).to eq(alice)
    end

    it "associates the update with a newsfeed item" do
      set_current_user(alice)
      post :create, status_update: {content: "I had a great day today"}

      newsfeed_item = NewsfeedItem.first
      expect(StatusUpdate.first.newsfeed_items).to eq([newsfeed_item])
    end

    it "saves the status update with its content" do
      set_current_user(alice)
      post :create, status_update: {content: "I had a great day today"}

      expect(StatusUpdate.first.content).to eq("I had a great day today")
    end
  end
end
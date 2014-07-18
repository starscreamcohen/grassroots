require 'spec_helper'

describe NewsfeedItemsController, :type => :controller do
  describe "GET index" do
    let!(:huggey_bears) {Fabricate(:organization, cause: "animals")}
    let!(:alice) {Fabricate(:organization_administrator, first_name: "Alice", organization_id: huggey_bears.id, user_group: "nonprofit")}
    let!(:bob) {Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
    let!(:cat) {Fabricate(:user, first_name: "Cat", user_group: "volunteer")}

    before do
      set_current_user(bob)
    end
    
    it "renders the index view" do
      get :index
      expect(response).to render_template(:index)
    end
    
    it "sets @relevant_activity" do
      get :index
      expect(assigns(:relevent_activity)).to match_array([])
    end

    it "shows all the activity of a followed user" do
      Fabricate(:relationship, follower_id: bob.id, leader_id: alice.id )
      graphic_design = Fabricate(:project, title: "graphic design", organization_id: huggey_bears.id)
      newsfeed_item = NewsfeedItem.create(user_id: alice.id)
      graphic_design.newsfeed_items << newsfeed_item

      wordpress = Fabricate(:project, title: "word press", organization_id: huggey_bears.id)
      newsfeed_item2 = NewsfeedItem.create(user_id: alice.id)
      wordpress.newsfeed_items << newsfeed_item2

      get :index
      expect(assigns(:relevent_activity)).to match_array([newsfeed_item, newsfeed_item2])
    end

    it "sets a newly initialized @user_update" do
      get :index
      expect(assigns(:status_update)).to be_instance_of(StatusUpdate)
    end

    it "sets a newly initialized @comment" do
      get :index
      expect(assigns(:comment)).to be_instance_of(Comment)
    end
  end
end
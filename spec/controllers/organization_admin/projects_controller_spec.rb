require 'spec_helper'

describe OrganizationAdmin::ProjectsController, :type => :controller do
  let!(:first_submitted_project) {Fabricate(:badge, name: "First Submitted Project")}
  
  describe "GET new" do
    it "renders the new template for creating a project" do
      alice = Fabricate(:user, organization_administrator: true, user_group: "nonprofit")
      session[:user_id] = alice.id
      get :new
      expect(response).to render_template(:new)
    end
    it "only renders this page for organization administrators" do
      bob = Fabricate(:user, organization_administrator: false, user_group: "nonprofit")
      session[:user_id] = bob.id
      get :new
      expect(response).to redirect_to(user_path(bob.id))
    end
    it "sets the @project" do
      alice = Fabricate(:user, organization_administrator: true, user_group: "nonprofit")
      session[:user_id] = alice.id
      
      get :new
      expect(assigns(:project)).to be_a Project
    end

    it "sets the project admin variable" do
      alice = Fabricate(:organization_administrator, user_group: "nonprofit")
      huggey_bears = Fabricate(:organization, user_id: alice.id)
      session[:user_id] = alice.id
      
      get :new, organization_id: huggey_bears.id
      expect(assigns(:project).project_admin).to eq(alice)
    end
  end

  describe "POST create" do
    
    let!(:huggey_bears) {Fabricate(:organization, cause: "animals")}
    let!(:alice) {Fabricate(:organization_administrator, first_name: "Alice", organization_id: huggey_bears.id, user_group: "nonprofit")}
    let!(:bob) {Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
    let!(:cat) {Fabricate(:user, first_name: "Cat", user_group: "volunteer")}

    before do
      huggey_bears.update_columns(user_id: alice.id)
      set_current_user(alice)
    end
    
    it "creates a project" do
      post :create, project: Fabricate.attributes_for(:project, title: "WordPress Site")
      expect(Project.count).to eq(1)
    end
    
    it "redirects to the organization administrator to the view project's show view" do
      post :create, project: Fabricate.attributes_for(:project, title: "WordPress Site")

      word_press = Project.first
      expect(response).to redirect_to(project_path(word_press.id))
    end

    it "creates a project associated with an organization" do
      post :create, project: Fabricate.attributes_for(:project, title: "WordPress Site", organization: huggey_bears)

      word_press = Project.first
      expect(word_press.organization).to eq(huggey_bears)
    end
    it "adds the created project to the organization's dashboard of projects" do
      post :create, project: Fabricate.attributes_for(:project, title: "WordPress Site", organization_id: huggey_bears.id)

      word_press = Project.first
      expect(huggey_bears.open_projects).to eq([word_press])
    end
    it "creates a project associated with a work-type" do
      post :create, project: Fabricate.attributes_for(:project, title: "WordPress Site", organization_id: huggey_bears.id, skills: "Web Development")

      word_press = Project.first
      expect(word_press.skills).to eq("Web Development")
    end

    it "creates a project associated with the organization's cause" do
      post :create, project: Fabricate.attributes_for(:project, title: "WordPress Site", organization_id: huggey_bears.id, skills: "Web Development")

      word_press = Project.first
      expect(word_press.causes).to eq("animals")
    end

    it "sets the project's state to open" do
      post :create, project: Fabricate.attributes_for(:project, title: "WordPress Site", organization_id: huggey_bears.id, skills: "Web Development")

      word_press = Project.first
      expect(word_press.state).to eq("open")
    end
    
    it "creates a newsfeed item" do
      post :create, project: Fabricate.attributes_for(:project, title: "WordPress Site", organization_id: huggey_bears.id, skills: "Web Development")

      expect(NewsfeedItem.count).to eq(1)
    end

    it "publishes this as activity on the newsfeed of others who follow the current user" do
      Fabricate(:relationship, follower_id: bob.id, leader_id: alice.id )
      graphic_design = Fabricate(:project, title: "graphic design", organization_id: huggey_bears.id)
      newsfeed_item2 = NewsfeedItem.create(user_id: alice.id)
      graphic_design.newsfeed_items << newsfeed_item2

      post :create, project: Fabricate.attributes_for(:project, title: "WordPress Site", organization_id: huggey_bears.id, skills: "Web Development")

      item = NewsfeedItem.first
      item2 = NewsfeedItem.last
      expect(NewsfeedItem.from_users_followed_by(bob)).to match_array([item, item2])
    end
  end

  describe "GET edit" do
    it "renders a form for the current user's profile" do
      huggey_bears = Fabricate(:organization)
      alice = Fabricate(:organization_administrator, organization_id: huggey_bears.id, user_group: "nonprofit")
      set_current_user(alice)
      word_press = Fabricate(:project, title: "WordPress Site", organization_id: huggey_bears.id)
      get :edit, id: word_press

      expect(response).to render_template(:edit)
    end
    it "sets the @project" do
      huggey_bears = Fabricate(:organization)
      alice = Fabricate(:organization_administrator, organization_id: huggey_bears.id, user_group: "nonprofit")
      set_current_user(alice)
      word_press = Fabricate(:project, title: "WordPress Site", organization_id: huggey_bears.id)
      get :edit, id: word_press

      expect(assigns(:project)).to be_a Project
    end
  end

  describe "PATCH update" do
    it "redirects to the project page" do
      huggey_bears = Fabricate(:organization)
      alice = Fabricate(:organization_administrator, organization_id: huggey_bears.id, user_group: "nonprofit")
      set_current_user(alice)
      word_press = Fabricate(:project, title: "WordPress Site", organization_id: huggey_bears.id)
      patch :update, id: alice.id, project: {description: "this site needs to be improved"} 

      expect(response).to redirect_to(project_path(word_press.id))
    end
    it "updates the project information" do
      huggey_bears = Fabricate(:organization)
      alice = Fabricate(:organization_administrator, organization_id: huggey_bears.id, user_group: "nonprofit")
      set_current_user(alice)
      word_press = Fabricate(:project, title: "WordPress Site", organization_id: huggey_bears.id)
      patch :update, id: alice.id, project: {description: "this site needs to be improved"} 

      expect(assigns(:project).description).to eq("this site needs to be improved")
    end
    it "flashes a notice that the user updated his/her project" do
      huggey_bears = Fabricate(:organization)
      alice = Fabricate(:organization_administrator, organization_id: huggey_bears.id, user_group: "nonprofit")
      set_current_user(alice)
      word_press = Fabricate(:project, title: "WordPress Site", organization_id: huggey_bears.id)
      patch :update, id: alice.id, project: {description: "this site needs to be improved"} 

      expect(flash[:success]).to eq("You updated your project")
    end
  end
end
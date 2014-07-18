require 'spec_helper'

describe UsersController, :type => :controller do
  describe "GET index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end

    it "sets @users" do
      bob = Fabricate(:user, first_name: "Bob", last_name: "Smith", user_group: "nonprofit")
      alice = Fabricate(:user, first_name: "Alice", last_name: "Smith", user_group: "nonprofit")
      cat = Fabricate(:user, first_name: "Cat", last_name: "Smith", user_group: "nonprofit")

      get :index
      expect(assigns(:users)).to match_array([bob, alice, cat])
    end
  end

  describe "GET show" do
    let!(:alice) {Fabricate(:user, user_group: "nonprofit")}
    let!(:bob) {Fabricate(:user, user_group: "volunteer")}

    before do
      set_current_user(alice)
    end

    it "shows the user's profile" do
      get :show, id: alice

      expect(response).to render_template(:show)
    end

    it "sets @relationships to the current users following relationships" do
      relationship = Relationship.create(follower: alice, leader: bob)
      get :show, id: alice

      expect(assigns(:relationships)).to eq([relationship])
    end

    it "sets @following_relationship" do
      relationship = Relationship.create(follower: alice, leader: bob)
      get :show, id: bob

      expect(assigns(:following_relationship)).to eq(relationship)
    end
  end

  
  describe "GET new" do
    it "renders the new template for unauthenticated users" do
      get :new
      expect(response).to render_template(:new)
    end
    it "sets @user to a new user" do
      get :new
      expect(assigns(:user)).to be_new_record
      expect(assigns(:user)).to be_instance_of User
    end
  end

  describe "POST create" do
    context "with valid data" do
      it "creates the user" do
        post :create, user: {first_name: "Alice", last_name: "Smith", password: "password", email: "alice@example.com", user_group: "nonprofit"}
        expect(User.count).to eq(1)
      end

      it "redirects the user to its profile page" do
        post :create, user: {first_name: "Alice", last_name: "Smith", password: "password", email: "alice@example.com", user_group: "nonprofit"}
        user = User.first
        expect(response).to redirect_to(user_path(user.id))
      end

      it "sets the user with either a volunteer or nonprofit type" do
        post :create, user: {first_name: "Alice", last_name: "Smith", password: "password", email: "alice@example.com", user_group: "volunteer"}
        user = User.first
        expect(user.user_group).to eq("volunteer")
      end
    end
    context "with invalid data" do
      it "does not create the user" do
        post :create, user: {first_name: "Alice", password: "password", email: "alice@example.com"}
        expect(User.count).to eq(0)
      end

      it "renders the new template" do
        post :create, user: {first_name: "Alice", password: "password", email: "alice@example.com"}
        expect(response).to render_template(:new)
      end
      it "flashes a notice" do
        post :create, user: {first_name: "Alice", password: "password", email: "alice@example.com"}
        expect(flash[:notice]).to be_present
      end
    end
    
    context "when sending emails" do

      after { ActionMailer::Base.deliveries.clear }

      it "sends out email to the user with valid inputs" do
        post :create, user: {email: "joe@example.com", password: "password", first_name: "Joe", last_name: "Smith", user_group: "nonprofit"}

        expect(ActionMailer::Base.deliveries.last.to).to eq(['joe@example.com'])
      end
      
      it "sends out email containing the user's name with valid inputs" do
        post :create, user: {email: "joe@example.com", password: "password", first_name: "Joe", last_name: "Smith", user_group: "nonprofit"}

        expect(ActionMailer::Base.deliveries.last.body).to include("Joe Smith")
      end
      
      it "does not send out email with invlid inputs" do
        #ActionMailer::Base.deliveries.clear
        post :create, user: {email: "joe@example.com", first_name: "Joe", last_name: "Smith", user_group: "nonprofit"}

        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end

  describe "GET edit" do
    it "renders a form for the current user's profile" do
      alice = Fabricate(:user, user_group: "nonprofit")
      get :edit, id: alice.id

      expect(response).to render_template(:edit)
    end
    
    it "sets the @user" do
      alice = Fabricate(:user, user_group: "nonprofit")
      get :edit, id: alice.id

      expect(assigns(:user)).to be_a User
    end
  end

  describe "PATCH update" do

    context "when the user is affiliated with an organization" do
      let!(:huggey_bear) {Fabricate(:organization)}
      let!(:alice) {Fabricate(:user, user_group: "nonprofit")}

      before do
        set_current_user(alice)
      end

      it "redirects to the user's profile page" do
        patch :update, id: alice.id, user: {first_name: alice.first_name, last_name: alice.last_name, email: "test@example.com", organization_name_box: huggey_bear.name} 

        expect(response).to redirect_to(user_path(alice.id))
      end
      
      it "updates the user's information" do
        patch :update, id: alice.id, user: {first_name: alice.first_name, last_name: "Adams", email: "test@example.com", organization_name_box: huggey_bear.name} 

        expect(alice.reload.last_name).to eq("Adams")
      end
      
      it "flashes a notice that the user updated his/her profile" do
        patch :update, id: alice.id, user: {first_name: alice.first_name, last_name: alice.last_name, email: "test@example.com", organization_name_box: huggey_bear.name} 
        
        expect(flash[:notice]).to eq("You have updated your profile successfully.")
      end
    end
    context "when the user's organization is not present" do

      let!(:alice) {Fabricate(:user, user_group: "nonprofit")}

      before do
        set_current_user(alice)
      end

      it "redirects the user to a form to create the organization" do
        patch :update, id: alice.id, user: {first_name: alice.first_name, last_name: alice.last_name, email: "test@example.com", organization_name_box: "The Red Cross"}  

        expect(response).to redirect_to(new_organization_admin_organization_path)
      end

      it "still updates the user's attributes" do
        patch :update, id: alice.id, user: {first_name: "Gil", last_name: alice.last_name, email: "test@example.com", organization_name_box: "The Red Cross"}  

        expect(alice.reload.first_name).to eq("Gil")
      end

      it "makes the user the administrator of the absent organization" do
        patch :update, id: alice.id, user: {first_name: "Gil", last_name: alice.last_name, email: "test@example.com", organization_name_box: "The Red Cross"}  

        expect(alice.reload.organization_administrator).to eq(true)
      end
    end
    context "when the user is a freelancer" do
      let!(:jerry) {Fabricate(:user, user_group: "volunteer")}

      before do
        set_current_user(jerry)
      end

      it "redirects tot he users profile page" do
        patch :update, id: jerry.id, user: {first_name: "Jerry", last_name: jerry.last_name, email: "test@example.com"}
        
        expect(response).to redirect_to(user_path(jerry.id))
      end
      it "update's the volunteers information" do
        patch :update, id: jerry.id, user: {first_name: "Jerry", last_name: jerry.last_name, email: "test@example.com"}
        
        expect(jerry.reload.first_name).to eq("Jerry")
      end
    end

    context "when the user has 100% profile completion" do
      let!(:jerry) {Fabricate(:user, first_name: "Jerry", last_name: "Smith", user_group: "volunteer", 
        email: "test@example.com", interests: "", 
        contact_reason: "", state_abbreviation: "", city: "", 
        bio: "", position: "")}
      let!(:profile_completion) {Fabricate(:badge, name: "100% User Profile Completion")}

      before do
        set_current_user(jerry)
      end
      
      it "awards the user with the profile completion badge" do

        patch :update, id: jerry.id, user: {interests: "Environment", 
          contact_reason: "if you wanna hang out!", state_abbreviation: "AL", city: "Birmingham", 
          bio: "I like to juggle apples.", position: "Programmer"}

        expect(jerry.reload.badges).to match_array([profile_completion])
      end

      it "only awards the user with the badge once" do
        jerry.badges << profile_completion
        patch :update, id: jerry.id, user: {interests: "Environment", 
          contact_reason: "if you wanna hang out!", state_abbreviation: "AL", city: "Birmingham", 
          bio: "I like to juggle apples.", position: "Programmer"}

        expect(jerry.reload.badges.count).to eq(1)
      end

      it "creates a makes the badge a newsfeed item for the current user" do
        patch :update, id: jerry.id, user: {interests: "Environment", 
          contact_reason: "if you wanna hang out!", state_abbreviation: "AL", city: "Birmingham", 
          bio: "I like to juggle apples.", position: "Programmer"}

        expect(jerry.reload.newsfeed_items.count).to eq(1)
      end
    end
  end

  describe "DELETE remove" do
    context "when removing user from organization's profile" do
      it "redirects to the organization's profile page" do
        huggey_bear = Fabricate(:organization)
        alice = Fabricate(:user, organization_id: huggey_bear.id, user_group: "nonprofit")

        delete :remove, id: alice.id
        expect(response).to redirect_to organization_path(huggey_bear.id)
      end
      it "unassociates the staff member selected from the organization" do
        huggey_bear = Fabricate(:organization)
        alice = Fabricate(:user, organization_id: huggey_bear.id, user_group: "nonprofit")

        delete :remove, id: alice.id
        expect(alice.reload.organization_id).to be_nil
      end
    end
  end

  describe "GET search" do
    let!(:huggey_bear) {Fabricate(:organization, name: "Huggey Bear Land", cause: "Animal Rights", 
      ruling_year: 1998, mission_statement: "We want to give everyone a huggey bear in their sad times", 
      guidestar_membership: nil, ein: "192512653-6", street1: "2998 Hansen Heights", 
      street2: nil, city: "New York", state_abbreviation: 0, zip: "28200-1366", 
      ntee_major_category_id: 0, funding_method: nil, user_id: nil,budget: "$22,000,000.00", 
      contact_number: "555-555-5555", contact_email: "test@example.com", 
      goal: "We want 1 out of every 5 Americans to have a huggey bear.")}
    let!(:amnesty) {Fabricate(:organization, name: "Amnesty International", cause: "Human Rights", 
      ruling_year: 1912, mission_statement: "We want to see human rights spread across the globe -- chyea.", 
      guidestar_membership: nil, ein: "987931299-1", street1: "3293 Dunnit Hill", 
      street2: nil, city: "New York", state_abbreviation: 0, zip: "28200-1366", ntee_major_category_id: 0, 
      funding_method: nil, user_id: nil, budget: "$22,000,000.00", contact_number: "555-555-5555", 
      contact_email: "test@example.com", goal: "Every year we want at least one thousand human rights activists released from prisons around the world.")}

    let!(:alice_smith) {Fabricate(:user, organization_id: 1, first_name: "Alice", 
      last_name: "Smith", email: "alice@huggey_bear.org", 
      interests: "animal rights", street1: nil, street2: nil, 
      city: "New York", state_abbreviation: "NY", phone_number: nil, zip: nil, 
      organization_administrator: true, organization_staff: nil, volunteer: nil, 
      position: "Executive Director", user_group: "nonprofit")}
    let!(:bob_adams) {Fabricate(:user, organization_id: 2, first_name: "Bob", 
      last_name: "Adams", email: "bob@amnesty.org", 
      interests: "human rights", street1: nil, street2: nil, 
      city: "Miami", state_abbreviation: "FL", phone_number: nil, zip: nil, 
      organization_administrator: true, organization_staff: nil, volunteer: nil, 
      position: "Executive Director", user_group: "nonprofit")}

    let!(:cat_mckenzie) {Fabricate(:user, organization_id: 1, first_name: "Catherine", 
      last_name: "McKenzie", email: "cat@huggey_bear.org", 
      interests: "animal rights", street1: nil, street2: nil, 
      city: "San Francisco", state_abbreviation: "CA", phone_number: nil, zip: nil, 
      organization_staff: true, position: "designer", user_group: "nonprofit")}
    let!(:dan_quale) {Fabricate(:user, organization_id: 1, first_name: "Dan", 
      last_name: "Quale", email: "dan@amnesty.org", 
      interests: "human rights", street1: nil, street2: nil, 
      city: "New York", state_abbreviation: "NY", phone_number: nil, zip: nil, 
      organization_staff: true, position: "developer", user_group: "nonprofit")}

    let!(:elena_washington) {Fabricate(:user, first_name: "Elena", last_name: "Washington", 
      email: "elena@example.org", interests: "urban affairs", 
      street1: nil, street2: nil, city: "New York", state_abbreviation: "NY", phone_number: nil, 
      zip: nil, organization_administrator: nil, organization_staff: nil, volunteer: true, 
      user_group: "volunteer", position: nil)}
    let!(:frank_daniels) {Fabricate(:user, first_name: "Frank", last_name: "Daniels", 
      email: "frank@example.org", interests: "environment",
      street1: nil, street2: nil, city: "Birmingham", state_abbreviation: "AL", phone_number: nil, 
      zip: nil, organization_administrator: nil, organization_staff: nil, volunteer: true, 
      user_group: "volunteer", position: nil)}
    let!(:george_smith) {Fabricate(:user, first_name: "George", last_name: "Smith", 
      email: "george@example.org", interests: "human rights",
      street1: nil, street2: nil, city: "Boston", state_abbreviation: "MA", phone_number: nil, 
      zip: nil, organization_administrator: nil, organization_staff: nil, volunteer: true, 
      user_group: "volunteer", position: nil)}
    let!(:harry_ortega) {Fabricate(:user, first_name: "Harry", last_name: "Ortega", 
      email: "harry@example.org", interests: "animal rights", 
      street1: nil, street2: nil, city: "Boston", state_abbreviation: "MA", phone_number: nil, 
      zip: nil, organization_administrator: nil, organization_staff: nil, volunteer: true, 
      user_group: "volunteer", position: nil)}
    let!(:isabel_david) {Fabricate(:user, first_name: "Isabel", last_name: "David", 
      email: "isabel@example.org", interests: "environment", 
      street1: nil, street2: nil, city: "New York", state_abbreviation: "NY", phone_number: nil, 
      zip: nil, organization_administrator: nil, organization_staff: nil, volunteer: true, 
      user_group: "volunteer", position: nil)}
    let!(:jacob_seltzer) {Fabricate(:user, first_name: "Jacob", last_name: "Seltzer", 
      email: "jacob@example.org", interests: "urban affairs", 
      street1: nil, street2: nil, city: "New York", state_abbreviation: "NY", phone_number: nil, 
      zip: nil, organization_administrator: nil, organization_staff: nil, volunteer: true, 
      user_group: "volunteer", position: nil)}

    let!(:web_development) {Fabricate(:skill, name: "web development")}

    context "when only using the checkbox filters" do
      it "redirects to the results page" do
        get :search

        expect(response).to render_template(:search)
      end

      it "shows only the users within a certain skill set" do
        bob_adams.skills << web_development
        isabel_david.skills << web_development
        dan_quale.skills << web_development
        jacob_seltzer.skills << web_development
        george_smith.skills << web_development

        get :search, skills: "web development"

        expect(assigns(:results)).to eq([bob_adams, isabel_david, dan_quale, jacob_seltzer, george_smith])
      end

      it "shows the users under a certain cause" do
        get :search, interests: "human rights"

        expect(assigns(:results)).to eq([bob_adams, dan_quale, george_smith])
      end

      it "shows the users under a certain state" do
        get :search, state_abbreviation: "MA"

        expect(assigns(:results)).to eq([harry_ortega, george_smith])
      end

      it "shows the users under a certain city" do
        get :search, city: "Birmingham"

        expect(assigns(:results)).to eq([frank_daniels])
      end

      it "shows the users within a certain position" do
        get :search, position: "Executive Director"

        expect(assigns(:results)).to eq([bob_adams, alice_smith])
      end

      it "shows the users within a certain position" do
        get :search, interests: "urban affairs"

        expect(assigns(:results)).to eq([jacob_seltzer, elena_washington])
      end
    end
    context "when using the search bar" do
      #it "sets the @results variable by search term"
        #get :search, search_term: "smith", last_name:
      #it "removes duplicate items in @results" 
    end
  end
end
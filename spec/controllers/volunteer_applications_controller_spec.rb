require 'spec_helper'

describe VolunteerApplicationsController, :type => :controller do
  describe "GET new" do
    let(:alice) { Fabricate(:organization_administrator, organization_id: nil, first_name: "Alice", last_name: "Smith", user_group: "nonprofit") }
    let(:bob) { Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
    let(:huggey_bear) { Fabricate(:organization, user_id: alice.id) }
    let(:word_press) { Fabricate(:project, title: "word press website", user_id: alice.id, organization_id: huggey_bear.id, state: "open") }
    let(:contract) { Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id) } 

    context "when a submitting a volunteer application" do

      before do
        get :new, project_id: word_press.id
      end

      it "renders the new template for creating a volunteer application as a private message" do
        expect(response).to render_template(:new)
      end
    
      it "sets @private_message" do
        expect(assigns(:private_message)).to be_instance_of(PrivateMessage)
      end

      it "sets the project id in the initialized @private_message" do
        expect(assigns(:private_message).project_id).to eq(1)
      end
      
      it "sets the recipient value in the initialized @private_message" do
        expect(assigns(:private_message).recipient).to eq(alice)
      end
  
      it "sets the subject line with the value of the project title with Project Request: in the initialized @private_message" do
        expect(assigns(:private_message).subject).to eq("Project Request: word press website")
      end
    end

  end

  describe "POST create" do
    let(:alice) { Fabricate(:organization_administrator, organization_id: nil, first_name: "Alice", last_name: "Smith", user_group: "nonprofit") }
    let(:bob) { Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
    let(:huggey_bear) { Fabricate(:organization, user_id: alice.id) }
    let(:word_press) { Fabricate(:project, title: "word press website", user_id: alice.id, organization_id: huggey_bear.id, state: "open") }
    let(:contract) { Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id) } 

    before do
      set_current_user(bob)
    end

    it "renders the current user's inbox" do
      post :create, project_id: word_press.id, private_message: {recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project"}
      expect(response).to redirect_to(conversations_path)
    end
   
    it "creates a volunteer application" do
      post :create, private_message: {recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project"}, project_id: word_press.id
      expect(VolunteerApplication.count).to eq(1)
    end
   
    it "associates the application with the volunteer" do
      post :create, project_id: word_press.id, private_message: {recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project"}
      expect(VolunteerApplication.first.applicant).to eq(bob)
    end
   
    it "associates the application with the project" do
      post :create, project_id: word_press.id, private_message: {recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project"}
      expect(VolunteerApplication.first.project).to eq(word_press)
    end
    
    it "associates the application with a conversation" do  
      post :create, project_id: word_press.id, private_message: {recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project"}
      expect(Conversation.first.volunteer_application_id).to eq(1)
    end

    it "associates the conversation with the volunteer" do
      post :create, project_id: word_press.id, private_message: {recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project"}
      
      convo = Conversation.first
      bobs_sent_message = convo.private_messages.first
      expect(bob.sent_messages.first).to eq(bobs_sent_message)
    end
  end
end

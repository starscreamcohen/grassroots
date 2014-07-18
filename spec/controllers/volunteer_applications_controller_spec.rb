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
    
      it "sets @message" do
        expect(assigns(:message)).to be_instance_of(Message)
      end

      it "sets the project id in the initialized @message" do
        expect(assigns(:message).project_id).to eq(1)
      end
      
      it "sets the recipient value in the initialized @message" do
        expect(assigns(:message).recipient).to eq(alice)
      end
  
      it "sets the subject line with the value of the project title with Project Request: in the initialized @message" do
        expect(assigns(:message).subject).to eq("Project Request: word press website")
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
      post :create, project_id: word_press.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project"}
      expect(response).to redirect_to(conversations_path)
    end
   
    it "creates a volunteer application" do
      post :create, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project"}, project_id: word_press.id
      expect(VolunteerApplication.count).to eq(1)
    end
   
    it "associates the application with the volunteer" do
      post :create, project_id: word_press.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project"}
      expect(VolunteerApplication.first.applicant).to eq(bob)
    end
   
    it "associates the application with the project" do
      post :create, project_id: word_press.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project"}
      expect(VolunteerApplication.first.project).to eq(word_press)
    end
    
    it "associates the application with a conversation" do  
      post :create, project_id: word_press.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project"}
      expect(Conversation.first.volunteer_application_id).to eq(1)
    end

    it "associates the conversation with the volunteer" do
      post :create, project_id: word_press.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project"}
      
      convo = Conversation.first
      bobs_sent_message = convo.messages.first
      expect(bob.sent_messages.first).to eq(bobs_sent_message)
    end

    it "creates a following relationship" do
      post :create, project_id: word_press.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project"}

      expect(Relationship.count).to eq(2)
    end
    
    it "makes the volunteer follow the administrator" do
      post :create, project_id: word_press.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project"}

      expect(bob.follows?(alice)).to eq(true)
    end

    it "makes the administrator follow the volunteer" do
      post :create, project_id: word_press.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project"}

      expect(alice.follows?(bob)).to eq(true)
    end
  end
end


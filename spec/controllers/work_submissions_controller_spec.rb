require 'spec_helper'

describe WorkSubmissionsController, :type => :controller do
  describe "Get new" do
    let(:alice) {Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit")}
    let(:huggey_bear) { Fabricate(:organization, user_id: alice.id) }
    let(:bob) {Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
    
    let(:logo) { Fabricate(:project, title: "need a logo", user_id: alice.id, organization_id: huggey_bear.id, state: "open")  }
    let(:contract) { Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: logo.id) } 
    
    before do
      get :new, contract_id: contract.id
    end
    
    it "renders the submit_work_message template for notifying the contractor that work has been submitted " do
      expect(response).to render_template(:new)
    end

    it "sets @contract to allow for a conditional that 
      will change the form's route to update_contract_work_submitted controller action " do
      expect(assigns(:contract)).to be_instance_of(Contract)
    end

    it "sets @message with contractor as recipient of message" do
      expect(assigns(:message).recipient_id).to eq(alice.id)
    end
  end

  describe "POST create" do
    let(:alice) {Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit")}
    let(:huggey_bear) { Fabricate(:organization, user_id: alice.id) }
    let(:bob) {Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
    let(:cat) {Fabricate(:user, first_name: "Cat", user_group: "volunteer")}
    let(:dan) {Fabricate(:user, first_name: "Dan", user_group: "volunteer")}
    
    let(:logo) { Fabricate(:project, title: "need a logo", user_id: alice.id, organization_id: huggey_bear.id, state: "open")  }
    let(:word_press) { Fabricate(:project, title: "word press website", user_id: alice.id, organization_id: huggey_bear.id, state: "open") }

    let(:contract) { Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id) } 
    let(:conversation) { Fabricate(:conversation, contract_id: contract.id) }
    let(:message1) {Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")}
    let(:message2) {Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I've accepted you to join")}
    
    before do
      set_current_user(bob)
      alice.update_columns(organization_id: huggey_bear.id)
      word_press.update_columns(state: nil)
    end

   
    it "renders the current user's inbox" do
      post :create, id: contract.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}

      expect(response).to redirect_to(conversations_path)
    end

    it "makes the contract reflect that the volunteer has submitted work" do
      post :create, id: contract.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}

      expect(contract.reload.work_submitted).to eq(true)
    end

    it "makes the contract reflect that the project is still active" do
      post :create, id: contract.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}

      expect(contract.reload.active).to eq(true)
    end

    it "moves the project from in production to a state of, has work submitted" do
      post :create, id: contract.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}

      expect(word_press.reload.has_submitted_work?).to eq(true)
    end

    it "makes the project return false when asked if, in production" do
      post :create, id: contract.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}

      expect(word_press.reload.in_production?).to eq(false)
    end

    it "shows that the current user has a project with work submitted" do
      post :create, id: contract.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}

      expect(bob.submitted_work).to eq([word_press])
      expect(bob.submitted_work.count).to eq(1)
    end

    it "makes the volunteer send a message to the administrator" do
      post :create, id: contract.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}
      
      expect(bob.sent_messages.count).to eq(1)
    end

    it "starts a new conversation with the administrator" do
      post :create, id: contract.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}
      
      expect(alice.inbox.count).to eq(1)
    end

    it "associated the conversation with the contract " do
      conversation.messages << [message1, message2]
      post :create, id: contract.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}

      conversation = Conversation.last
      expect(conversation.reload.contract_id).to eq(contract.id)
    end

    it "makes the contract reflect that the volunteer has submitted work" do
      post :create, id: contract.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}  

      expect(contract.reload.work_submitted).to eq(true)
    end

    it "renders the conversation show view" do
      post :create, id: contract.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}  

      expect(response).to redirect_to(conversations_path)
    end

    it "sets the previous conversation's contract id to nil" do
      conversation.messages << [message1, message2]

      post :create, id: contract.id, message: {recipient_id: alice.id, sender_id: bob.id, subject: "Contract Complete", body: "This work is done"}  
      conversation2 = Conversation.first
      expect(conversation2.reload.contract_id).to eq(nil)
    end
  end
end
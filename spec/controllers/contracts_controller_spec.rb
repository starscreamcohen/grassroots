require 'spec_helper'

describe ContractsController, :type => :controller do
  describe "GET new" do

    let(:alice) {Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit")}
    let(:huggey_bear) { Fabricate(:organization, user_id: alice.id) }
    let(:bob) {Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
    let(:cat) {Fabricate(:user, first_name: "Cat", user_group: "volunteer")}
    let(:dan) {Fabricate(:user, first_name: "Dan", user_group: "volunteer")}
    
    let(:logo) { Fabricate(:project, title: "need a logo", user_id: alice.id, organization_id: huggey_bear.id, state: "open")  }
    let(:word_press) { Fabricate(:project, title: "word press website", user_id: alice.id, organization_id: huggey_bear.id, state: "open") }

    let(:contract) { Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id) } 
    
    before do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id, accepted: true, rejected: false) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
      message2 = Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I've accepted you to join")

      get :new, contract_id: contract.id
    end
    
    it "renders the new template for creating a request as a private message for the project administrator to review the volunteer's work" do
      expect(response).to render_template(:new)
    end

    it "sets @message with project administrator as recipient of message" do
      expect(assigns(:message)).to be_instance_of(Message)
    end

    it "sets the recipient value in the initialized @message" do

      expect(assigns(:message).recipient).to eq(alice)
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
    let(:application) { Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id)  }
    let(:conversation) { Fabricate(:conversation, volunteer_application_id: application.id) }
    let(:message) { Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")  }


    before do
      set_current_user(alice)
      huggey_bear.update_columns(user_id: alice.id)
      alice.update_columns(organization_id: huggey_bear.id)
    end

    it "renders the conversation show view" do
      post :create, volunteer_application_id: conversation.volunteer_application_id, conversation_id: conversation.id

      expect(response).to redirect_to(conversation_path(conversation.id))
    end
    it "creates a contract" do
      post :create, volunteer_application_id: conversation.volunteer_application_id, conversation_id: conversation.id

      expect(Contract.count).to eq(1)
    end

    it "makes the volunteer application accepted" do
      post :create, volunteer_application_id: conversation.volunteer_application_id, conversation_id: conversation.id

      expect(application.reload.accepted).to eq(true)
    end

    it "makes the volunteer's application rejected status, false" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(application1.reload.rejected).to eq(false)
    end

    it "makes the other volunteer applications rejected" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 

      application2 = Fabricate(:volunteer_application, applicant_id: cat.id, administrator_id: alice.id, project_id: word_press.id)
      conversation2 = Fabricate(:conversation, volunteer_application_id: application2.id)  
      message2 = Fabricate(:message, recipient_id: alice.id, sender_id: cat.id, conversation_id: conversation2.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 

      application3 = Fabricate(:volunteer_application, applicant_id: dan.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation3 = Fabricate(:conversation, volunteer_application_id: application3.id) 
      message3 = Fabricate(:message, recipient_id: alice.id, sender_id: dan.id, conversation_id: conversation3.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(application2.reload.rejected).to eq(true)
      expect(application3.reload.rejected).to eq(true)
    end

    it "makes the contract active " do
      post :create, volunteer_application_id: conversation.volunteer_application_id, conversation_id: conversation.id

      expect(Contract.first.active).to eq(true)
    end

    it "makes the organization administrator the owner of the contract" do

      post :create, volunteer_application_id: conversation.volunteer_application_id, conversation_id: conversation.id

      expect(Contract.first.contractor_id).to eq(alice.id)
    end
    
    it "makes the the applicant the volunteer of the contract" do
      post :create, volunteer_application_id: conversation.volunteer_application_id, conversation_id: conversation.id

      expect(Contract.first.reload.volunteer_id).to eq(bob.id)
    end
    it "associated the project with the contract" do
      post :create, volunteer_application_id: conversation.volunteer_application_id, conversation_id: conversation.id

      expect(Contract.first.project_id).to eq(word_press.id)
    end

    it "associated the volunteer with the project" do
      post :create, volunteer_application_id: conversation.volunteer_application_id, conversation_id: conversation.id

      expect(bob.projects_in_production).to eq([word_press])
    end

    it "associates the project with the volunteer" do
      post :create, volunteer_application_id: conversation.volunteer_application_id, conversation_id: conversation.id

      expect(word_press.reload.volunteers).to eq([bob])
    end

    it "moves the project's state into, in production" do
      post :create, volunteer_application_id: conversation.volunteer_application_id, conversation_id: conversation.id

      expect(bob.projects_in_production).to eq([word_press])
    end

    it "updates the conversations contract value to the id of the contract" do
      post :create, volunteer_application_id: conversation.volunteer_application_id, conversation_id: conversation.id

      expect(conversation.reload.contract_id).to eq(Contract.first.id)
    end

    it "updates the conversations application value to nil" do
      post :create, volunteer_application_id: conversation.volunteer_application_id, conversation_id: conversation.id

      expect(conversation.reload.volunteer_application_id).to eq(nil)
    end

    it "changes the project's state from open to nil" do
      post :create, volunteer_application_id: conversation.volunteer_application_id, conversation_id: conversation.id

      expect(word_press.reload.state).to eq(nil)
    end

    it "makes the organization have a project in production" do
      post :create, volunteer_application_id: conversation.volunteer_application_id, conversation_id: conversation.id

      expect(huggey_bear.in_production_projects).to eq([word_press])
    end

    it "removes the application ids from the other conversations with rejected volunteer application ids" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 

      application2 = Fabricate(:volunteer_application, applicant_id: cat.id, administrator_id: alice.id, project_id: word_press.id)
      conversation2 = Fabricate(:conversation, volunteer_application_id: application2.id)  
      message2 = Fabricate(:message, recipient_id: alice.id, sender_id: cat.id, conversation_id: conversation2.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 

      application3 = Fabricate(:volunteer_application, applicant_id: dan.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation3 = Fabricate(:conversation, volunteer_application_id: application3.id) 
      message3 = Fabricate(:message, recipient_id: alice.id, sender_id: dan.id, conversation_id: conversation3.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(conversation2.reload.volunteer_application_id).to eq(nil)
      expect(conversation3.reload.volunteer_application_id).to eq(nil)
      expect(conversation1.reload.volunteer_application_id).to eq(nil)
    end

    it "does not assign the contract value to any of the conversations which previously contained the rejected volunteer applications" do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation1 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message1 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 

      application2 = Fabricate(:volunteer_application, applicant_id: cat.id, administrator_id: alice.id, project_id: word_press.id)
      conversation2 = Fabricate(:conversation, volunteer_application_id: application2.id)  
      message2 = Fabricate(:message, recipient_id: alice.id, sender_id: cat.id, conversation_id: conversation2.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 

      application3 = Fabricate(:volunteer_application, applicant_id: dan.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation3 = Fabricate(:conversation, volunteer_application_id: application3.id) 
      message3 = Fabricate(:message, recipient_id: alice.id, sender_id: dan.id, conversation_id: conversation3.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 
      post :create, volunteer_application_id: conversation1.volunteer_application_id, conversation_id: conversation1.id

      expect(conversation1.reload.contract_id).to eq(1)
      expect(conversation2.reload.contract_id).to eq(nil)
      expect(conversation3.reload.contract_id).to eq(nil)
    end    
  end

  describe "DELETE destroy" do
    let(:alice) {Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit")}
    let(:huggey_bear) { Fabricate(:organization, user_id: alice.id) }
    let(:bob) {Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
    let(:cat) {Fabricate(:user, first_name: "Cat", user_group: "volunteer")}
    let(:dan) {Fabricate(:user, first_name: "Dan", user_group: "volunteer")}
    
    let(:logo) { Fabricate(:project, title: "need a logo", user_id: alice.id, organization_id: huggey_bear.id, state: "open")  }
    let(:word_press) { Fabricate(:project, title: "word press website", user_id: alice.id, organization_id: huggey_bear.id) }

    let(:contract) { Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id) } 
    let(:conversation) { Fabricate(:conversation, contract_id: contract.id) }
    let(:message1) {Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")}
    let(:message2) {Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I've accepted you to join")}

    before do
      set_current_user(alice)
      alice.update_columns(organization_id: huggey_bear.id)
    end

    it "renders the conversation show view" do
      conversation.messages << [message1, message2]
      patch :destroy, id: contract.id

      expect(response).to redirect_to(conversation_path(conversation.id))
    end

    it "sets the status of the contract, dropped_out, to true" do
      conversation.messages << [message1, message2]
      patch :destroy, id: contract.id
      
      expect(contract.reload.dropped_out).to eq(true)
    end

    it "sets the status of the contract, active, to false" do
      conversation.messages << [message1, message2]
      patch :destroy, id: contract.id
      
      expect(contract.reload.active).to eq(false)
    end

    it "automates a message to both parties" do
      conversation.messages << [message1, message2]
      patch :destroy, id: contract.id

      expect(conversation.messages.count).to eq(3)
    end

    it "clears the project of its volunteers" do
      conversation.messages << [message1, message2]
      patch :destroy, id: contract.id
    
      expect(word_press.volunteers).to eq([])
    end

    it "moves the project back to open" do
      conversation.messages << [message1, message2]
      patch :destroy, id: contract.id

      expect(word_press.reload.state).to eq("open")
    end

    it "reduces the number of projects in production for the user by one" do
      set_current_user(bob)
      conversation.messages << [message1, message2]
      patch :destroy, id: contract.id

      expect(bob.projects_in_production.count).to eq(0)
    end

=begin
      it "makes the volunteer still keep a record of the contract and its dropped out status" do
        conversation.messages << [message1, message2]
        patch :dropping_contract, id: contract.id

        contract = Contract.find_by(volunteer_id: bob.id)

        expect(bob.jobs).to eq([contract])
        #expect(contract.dropped_out).to eq(true)
        #expect(contract.active).to eq(false)
      end

      it "makes the contractor still keep a record of the contract and its dropped out status" do
        conversation.messages << [message1, message2]
        patch :dropping_contract, id: contract.id
        
        contract = Contract.find_by(contractor_id: alice.id)
        expect(alice.contracts).to eq([contract])
        #expect(contract.dropped_out).to eq(true)
        #expect(contract.active).to eq(false)
      end
=end
  end
    
  describe "PATCH upate" do
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
    end

    it "renders the conversation view" do
      contract = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: true)
      conversation = Fabricate(:conversation, contract_id: contract.id)
      message1 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
      message2 = Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I've accepted you to join")
      patch :update, id: contract.id

      expect(response).to redirect_to(conversation_path(conversation.id))
    end

    it "makes the contract complete" do
      contract = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: true)
      conversation = Fabricate(:conversation, contract_id: contract.id)
      message1 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
      message2 = Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I've accepted you to join")
      patch :update, id: contract.id

      expect(contract.reload.complete).to eq(true)
    end
  end
end
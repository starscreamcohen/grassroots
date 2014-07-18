require 'spec_helper'

describe User do
  it { should belong_to(:organization)}
  it { should have_many(:sent_messages)}
  it { should have_many(:received_messages).order("created_at DESC")}
  it { should have_many(:requests_to_volunteer)}
  it { should have_many(:volunteer_requests)}
  it { should have_many(:assignments)}
  it { should have_many(:delegated_projects)}
  it { should have_many(:questions)}
  it { should have_many(:accomplishments)}
  it { should have_many(:badges).through(:accomplishments)}
  it { should have_many(:talents)}
  it { should have_many(:skills).through(:talents)}

  it "generates a random token when the user is created for password reset" do
    alice = Fabricate(:user, user_group: "nonprofit")
    expect(alice.new_password_token).to be_present
  end

  let(:huggey_bear) {Fabricate(:organization)}
  let(:amnesty) {Fabricate(:organization)}
  let(:global) {Fabricate(:organization)}
  let(:alice) {Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit")}
  let(:bob) {Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
  let(:cat) {Fabricate(:organization_administrator, first_name: "Cat", user_group: "nonprofit")}
  let(:dan) {Fabricate(:organization_administrator, first_name: "Dan", user_group: "nonprofit")}
  
  let(:word_press) {Fabricate(:project, title: "word press website", user_id: alice.id, organization_id: huggey_bear.id, state: "open") }
  let(:logo) {Fabricate(:project, title: "need a logo", user_id: cat.id, organization_id: amnesty.id, state: "open")  }
  let(:accounting) {Fabricate(:project, title: "didn't do my taxes", user_id: dan.id, organization_id: global.id)}
  let(:grant_writing) {Fabricate(:project, title: "grant writing job", user_id: cat.id, organization_id: amnesty.id) }

  describe "#open_applications" do
    let!(:alice) {Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit")}
    let!(:bob) {Fabricate(:user, first_name: "Bob", user_group: "volunteer")}
    let!(:cat) {Fabricate(:organization_administrator, first_name: "Cat", user_group: "nonprofit")}
    let!(:dan) {Fabricate(:organization_administrator, first_name: "Dan", user_group: "nonprofit")}
    let!(:word_press) {Fabricate(:project, title: "word press website", user_id: alice.id, organization_id: huggey_bear.id, state: "open") }
    let!(:logo) {Fabricate(:project, title: "need a logo", user_id: cat.id, organization_id: amnesty.id, state: "open")  }
    let!(:accounting) {Fabricate(:project, title: "didn't do my taxes", user_id: dan.id, organization_id: global.id)}

    it "shows the projects that the volunteer has applied to and not heard back from" do
      contract1 = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: nil)
      contract2 = Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: true, project_id: logo.id, work_submitted: nil)
      contract3 = Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: nil, project_id: accounting.id)

      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id, accepted: nil, rejected: nil)
      application2 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: cat.id, project_id: logo.id, accepted: nil, rejected: nil)
      application3 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: dan.id, project_id: accounting.id, accepted: false, rejected: true)

      expect(bob.open_applications.count).to eq(2)
    end
  end
  

  describe "#messages" do
    it "returns all the conversations of the user in an arry" do
      convo = Conversation.create
      message1 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project", conversation_id: convo.id)
      message2 = Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, subject: "Please let me join your project", body: "Sounds good. what's your phone number?", conversation_id: convo.id)
      message3 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "my phone number is 123455", conversation_id: convo.id)
      message4 = Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, subject: "Please let me join your project", body: "Great I will call you in a bit", conversation_id: convo.id)

      expect(bob.messages).to eq([message1, message2, message3, message4])
    end
  end


  describe "#inbox" do
    it "returns a conversation of the user in an arry if there is only one received smessages" do
      convo1 = Conversation.create
      message1 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project", conversation_id: convo1.id)
      
      expect(alice.inbox).to eq([convo1])
    end

    it "does not return a conversation of the user in an arry if there is only one sent smessages" do
      convo1 = Conversation.create
      bob = Fabricate(:user, first_name: "Bob", user_group: "nonprofit")
      alice = Fabricate(:user, first_name: "Alice", user_group: "volunteer")
      
      message1 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project", conversation_id: convo1.id)
      

      expect(bob.inbox).to eq([])
    end

    it "returns an array of multiple conversations of the user if there are multiple senders" do
      convo1 = Conversation.create
      convo2 = Conversation.create
      convo3 = Conversation.create

      message1 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project", conversation_id: convo1.id)
      message2 = Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, subject: "Please let me join your project", body: "Sounds good. what's your phone number?", conversation_id: convo1.id)
      message3 = Fabricate(:message, recipient_id: alice.id, sender_id: cat.id, subject: "Please let me join your project", body: "I'd really like to help out with your project", conversation_id: convo2.id)
      message4 = Fabricate(:message, recipient_id: cat.id, sender_id: alice.id, subject: "Please let me join your project", body: "Let's talk. I think you could be a great asset.", conversation_id: convo2.id)
      message5 = Fabricate(:message, recipient_id: alice.id, sender_id: dan.id, subject: "Please let me join your project", body: "I think your project is cool, and I want to help out.", conversation_id: convo3.id)

      expect(alice.inbox).to eq([convo1, convo2, convo3])
    end

    it "does not return duplicate conversations" do
      convo1 = Conversation.create
      convo2 = Conversation.create
      convo3 = Conversation.create
      
      bob = Fabricate(:user, first_name: "Bob", user_group: "volunteer")
      alice = Fabricate(:user, first_name: "Alice", user_group: "nonprofit")

      message1 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project", conversation_id: convo1.id)
      message2 = Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, subject: "Please let me join your project", body: "Sounds good. what's your phone number?", conversation_id: convo2.id)
      message3 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd really like to help out with your project", conversation_id: convo3.id)
      

      expect(alice.inbox).to eq([convo1, convo3])
    end
  end

  describe "#organization_name" do
    let(:alice) {Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit")}
    let(:huggey_bear) {Fabricate(:organization, user_id: alice.id)}
    
    it "returns the name of the organization of the user" do
      alice.update_columns(organization_id: huggey_bear.id)
      expect(alice.organization.name).to eq(huggey_bear.name)
    end
  end

  describe "#projects_in_production" do
    it "returns the projects that are in production because of a contract" do    
      accounting = Fabricate(:project, title: "didn't do my taxes", user_id: cat.id, organization_id: amnesty.id)

      contract1 =  Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: false)
      contract2 =  Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: true, project_id: logo.id, work_submitted: false)
      contract3 = Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: nil, project_id: accounting.id)

      expect(bob.projects_in_production).to eq([word_press, logo])
    end

    describe "#submitted_work" do  
      it "returns all the projects for which the volunteer has submitted work to the contractor" do
        accounting = Fabricate(:project, title: "didn't do my taxes", user_id: cat.id, organization_id: amnesty.id)

        contract1 =  Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: true, incomplete: false)
        contract2 = Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: true, project_id: logo.id, work_submitted: true, incomplete: false)
        contract3 = Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: true, project_id: accounting.id, work_submitted: false)

        expect(bob.submitted_work).to eq([word_press, logo])
      end
    end

    describe "#completed_projects" do
      it "returns all the projects for which the volunteer has completed" do

        accounting = Fabricate(:project, title: "didn't do my taxes", user_id: cat.id, organization_id: amnesty.id)

        contract1 =  Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: true)
        contract2 = Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: false, project_id: logo.id, work_submitted: false, complete: true)
        contract3 = Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: true, project_id: accounting.id, work_submitted: false)

        expect(bob.completed_projects).to eq([logo])
      end
    end

    describe "#projects_with_open_applications" do
      it "returns all the projects to which the volunteer applied" do  
        application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id)
        application2 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: accounting.id, rejected: true)
        application3 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: cat.id, project_id: logo.id)
        application4 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: cat.id, project_id: grant_writing.id, accepted: true)

        expect(bob.projects_with_open_applications).to eq([word_press, logo])
      end
    end

    describe "drop_contract(agreement)" do 
      it "dissassociates the user from the contract when the user wants to drop it" do
        accounting = Fabricate(:project, title: "didn't do my taxes", user_id: cat.id, organization_id: amnesty.id)
        contract1 =  Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: true)
        contract2 = Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: false, project_id: logo.id, work_submitted: false, complete: true)
        contract3 = Fabricate(:contract, contractor_id: cat.id, volunteer_id: bob.id, active: true, project_id: accounting.id)
        bob.drop_contract(contract3)

        expect(bob.projects_in_production).to eq([])
      end
    end


    describe "#administrated_projects" do
      let(:alice) {Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit")}
      let(:huggey_bear) {Fabricate(:organization, user_id: alice.id)}
      let(:word_press) {Fabricate(:project, title: "word press website", organization_id: huggey_bear.id, state: "open") }
      let(:logo) {Fabricate(:project, title: "need a logo", organization_id: huggey_bear.id, state: "open")  }
      let(:accounting) {Fabricate(:project, title: "didn't do my taxes", organization_id: huggey_bear.id, state: "open")}
      

      it "returns an array of projects which belong to the organization" do
        expect(alice.administrated_projects).to eq([word_press, logo, accounting])
      end
    end


    describe "#administrated_organization" do
      let!(:alice) {Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit")}
      let!(:huggey_bear) {Fabricate(:organization, user_id: alice.id)}
      let!(:amnesty) {Fabricate(:organization)}

      it "returns the organization which the user has" do
        alice.update_columns(organization_id: huggey_bear.id)
        expect(alice.administrated_organization).to eq(huggey_bear)
      end
    end

    describe "#update_profile_progress" do
      it "returns 18 for the user's profile completion if the user only has first and last name" do
        bob = User.create(first_name: "bob", last_name: "smith", user_group: "volunteer")
        expect(bob.update_profile_progress).to eq(25)
      end

      it "returns 100 for the user's profile completion if the user has everything filled out" do
        bob = User.create(email: "bob@example.com", first_name: "Bob", last_name:"Smith", 
          contact_reason: "if you wanna hang out!", state_abbreviation: "AL", 
          city: "Birmingham", bio: "I like to juggle apples.", position: "CEO")

        expect(bob.update_profile_progress).to eq(100)
      end
    end

    describe "#awarded?(badge)" do
      let!(:alice) {Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit")}
      let!(:profile_completion) {Fabricate(:badge, name: "100% User Profile Completion")}

      it "returns false when the user does not have the badge" do
        expect(alice.awarded?(profile_completion)).to eq(false)
      end

      it "returns true if the user has the badge" do
        alice.badges << profile_completion

        expect(alice.awarded?(profile_completion)).to eq(true)
      end
    end

    describe "#follows?" do
      it "returns true if the user yhas a following relationship with another user" do
        alice = Fabricate(:user, user_group: "volunteer")
        bob = Fabricate(:user, user_group: "volunteer")
        Fabricate(:relationship, leader: bob, follower: alice)
        expect(alice.follows?(bob)).to eq(true)
      end
      it "returns false if the user does not have a following relationship with another user" do
        alice = Fabricate(:user, user_group: "volunteer")
        bob = Fabricate(:user, user_group: "volunteer")
        Fabricate(:relationship, leader: alice, follower: bob)
        expect(alice.follows?(bob)).to eq(false)
      end
    end

    describe "#follow!" do
      it "makes the current user follow the other user" do
        alice = Fabricate(:user, user_group: "volunteer")
        bob = Fabricate(:user, user_group: "volunteer")
        alice.follow!(bob)

        expect(alice.follows?(bob)).to eq(true)
      end

      it "creates a newsfeed item for the current user" do
        alice = Fabricate(:user, user_group: "volunteer")
        bob = Fabricate(:user, user_group: "volunteer")
        alice.follow!(bob)

        expect(alice.reload.newsfeed_items.count).to eq(1)
      end
    end

    describe "#only_conversations" do
      let!(:convo1) {Fabricate(:conversation)}
      let!(:convo2) {Fabricate(:conversation)}
      let!(:convo3) {Fabricate(:conversation)}

      let!(:message1) {Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project", conversation_id: convo1.id)}
      let!(:message2) {Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, subject: "Please let me join your project", body: "Sounds good. what's your phone number?", conversation_id: convo1.id)}
      let!(:message3) {Fabricate(:message, recipient_id: alice.id, sender_id: cat.id, subject: "Please let me join your project", body: "I'd really like to help out with your project", conversation_id: convo2.id)}
      let!(:message4) {Fabricate(:message, recipient_id: cat.id, sender_id: alice.id, subject: "Please let me join your project", body: "Let's talk. I think you could be a great asset.", conversation_id: convo2.id)}
      let!(:message5) {Fabricate(:message, recipient_id: alice.id, sender_id: dan.id, subject: "Please let me join your project", body: "I think your project is cool, and I want to help out.", conversation_id: convo3.id)}

      it "shows the users conversations" do
        expect(alice.only_conversations).to match_array([convo1, convo2, convo3])
      end

      it "does not show conversations about volunteer applications" do
        application1 = Fabricate(:volunteer_application, applicant_id: cat.id, administrator_id: alice.id, project_id: word_press.id)
        convo4 = Fabricate(:conversation, volunteer_application_id: application1.id)  
        message7 = Fabricate(:message, recipient_id: alice.id, sender_id: cat.id, conversation_id: convo4.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 

        expect(alice.only_conversations).to match_array([convo1, convo2, convo3])
      end

      it "does not show conversations about contracts" do
        application1 = Fabricate(:volunteer_application, applicant_id: cat.id, administrator_id: alice.id, project_id: word_press.id)
        convo4 = Fabricate(:conversation, volunteer_application_id: application1.id)  
        message7 = Fabricate(:message, recipient_id: alice.id, sender_id: cat.id, conversation_id: convo4.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 

        contract = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: true)
        conversation = Fabricate(:conversation, contract_id: contract.id)
        message8 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        message9 = Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation.id, subject: "Please let me join your project", body: "I've accepted you to join")

        expect(alice.only_conversations).to match_array([convo1, convo2, convo3])
      end
    end
    describe "#only_conversations_about_work" do
      let!(:convo1) {Fabricate(:conversation)}
      let!(:convo2) {Fabricate(:conversation)}
      let!(:convo3) {Fabricate(:conversation)}

      let!(:message1) {Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, subject: "Please let me join your project", body: "I'd like to contribute to your project", conversation_id: convo1.id)}
      let!(:message2) {Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, subject: "Please let me join your project", body: "Sounds good. what's your phone number?", conversation_id: convo1.id)}
      let!(:message3) {Fabricate(:message, recipient_id: alice.id, sender_id: cat.id, subject: "Please let me join your project", body: "I'd really like to help out with your project", conversation_id: convo2.id)}
      let!(:message4) {Fabricate(:message, recipient_id: cat.id, sender_id: alice.id, subject: "Please let me join your project", body: "Let's talk. I think you could be a great asset.", conversation_id: convo2.id)}
      let!(:message5) {Fabricate(:message, recipient_id: alice.id, sender_id: dan.id, subject: "Please let me join your project", body: "I think your project is cool, and I want to help out.", conversation_id: convo3.id)}

      it "only shows conversations about work" do
        application1 = Fabricate(:volunteer_application, applicant_id: cat.id, administrator_id: alice.id, project_id: word_press.id)
        convo4 = Fabricate(:conversation, volunteer_application_id: application1.id)  
        message7 = Fabricate(:message, recipient_id: alice.id, sender_id: cat.id, conversation_id: convo4.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 

        contract = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: true)
        convo5 = Fabricate(:conversation, contract_id: contract.id)
        message8 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: convo5.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        message9 = Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, conversation_id: convo5.id, subject: "Please let me join your project", body: "I've accepted you to join")

        expect(alice.only_conversations_about_work).to match_array([convo4, convo5])
      end

      it "does not show conversations without contract or application values" do
        application1 = Fabricate(:volunteer_application, applicant_id: cat.id, administrator_id: alice.id, project_id: word_press.id)
        convo4 = Fabricate(:conversation, volunteer_application_id: application1.id)  
        message7 = Fabricate(:message, recipient_id: alice.id, sender_id: cat.id, conversation_id: convo4.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 

        contract = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: true)
        convo5 = Fabricate(:conversation, contract_id: contract.id)
        message8 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: convo5.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
        message9 = Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, conversation_id: convo5.id, subject: "Please let me join your project", body: "I've accepted you to join")

        expect(alice.only_conversations_about_work).to_not match_array([convo1, convo2, convo3])
      end
    end
  end
end
  
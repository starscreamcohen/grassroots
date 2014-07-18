require 'spec_helper'

describe WorkConversationsController, :type => :controller do
  describe "Get index" do
    let!(:alice) { Fabricate(:organization_administrator, first_name: "Alice", user_group: "nonprofit") }
    let!(:bob) { Fabricate(:user, first_name: "Bob", user_group: "volunteer") }
    let!(:cat) {Fabricate(:user, user_group: "volunteer")}
    let!(:huggey_bear) { Fabricate(:organization, user_id: alice.id) }
    let!(:word_press) { Fabricate(:project, title: "word press website", user_id: alice.id, organization_id: huggey_bear.id, state: "open") }
    let!(:conversation1) {Fabricate(:conversation)}
    let!(:conversation2) {Fabricate(:conversation)}
    let!(:message1) {Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")}
    let!(:message2) {Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation1.id, subject: "Please let me join your project", body: "OK great. when can you start?") }
    let!(:message3) {Fabricate(:message, recipient_id: alice.id, sender_id: cat.id, conversation_id: conversation2.id, subject: "Employment info", body: "I think I use to work at your organization")}
    let!(:message4) {Fabricate(:message, recipient_id: cat.id, sender_id: alice.id, conversation_id: conversation2.id, subject: "Employment info", body: "O reall? When did you start?") }

    before do
      set_current_user(alice)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end
    
    it "shows conversations about applications and contracts " do
      application1 = Fabricate(:volunteer_application, applicant_id: bob.id, administrator_id: alice.id, project_id: word_press.id) 
      conversation3 = Fabricate(:conversation, volunteer_application_id: application1.id) 
      message5 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation3.id, subject: "Please let me join your project", body: "I'd like to contribute to your project") 

      contract = Fabricate(:contract, contractor_id: alice.id, volunteer_id: bob.id, active: true, project_id: word_press.id, work_submitted: true)
      conversation4 = Fabricate(:conversation, contract_id: contract.id)
      message6 = Fabricate(:message, recipient_id: alice.id, sender_id: bob.id, conversation_id: conversation4.id, subject: "Please let me join your project", body: "I'd like to contribute to your project")
      message7 = Fabricate(:message, recipient_id: bob.id, sender_id: alice.id, conversation_id: conversation4.id, subject: "Please let me join your project", body: "I've accepted you to join")
      get :index

      expect(assigns(:work)).to match_array([conversation3, conversation4])
    end
  end
end
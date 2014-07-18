require 'spec_helper'

describe AnswersController, :type => :controller do
  describe "POST create" do
    let!(:alice) {Fabricate(:user, user_group: "nonprofit")}
    let!(:alice_question1) {Fabricate(:question, user_id: alice.id)}
    let!(:bob) {Fabricate(:user, user_group: "volunteer")}

    before(:each) do
      set_current_user(bob)
      request.env["HTTP_REFERER"] = "/questions/1" unless request.nil? or request.env.nil?
    end

    it "renders the show view of the question that it answers" do
      post :create, answer: {user_id: bob.id, description: "you want to do this and that"}, question_id: alice_question1.id

      expect(response).to redirect_to(question_path(alice_question1.id))
    end

    it "creates a answer" do
      post :create, answer: {user_id: bob.id, description: "you want to do this and that"}, question_id: alice_question1.id

      expect(Answer.count).to eq(1)
    end

    it "creates a question associated with a user" do
      post :create, answer: {user_id: bob.id, description: "you want to do this and that"}, question_id: alice_question1.id

      expect(Answer.first.author).to eq(bob)
    end
    it "creates a question associated with a question" do
      post :create, answer: {user_id: bob.id, description: "you want to do this and that"}, question_id: alice_question1.id

      expect(Answer.first.question).to eq(alice_question1)
    end

    it "does not create an answer which is an empty string" do
      post :create, answer: {user_id: bob.id, description: ""}, question_id: alice_question1.id

      expect(Answer.count).to eq(0)
    end
    it "publishes this as activity on the newsfeed of others who follow the current user" do
      Fabricate(:relationship, follower_id: alice.id, leader_id: bob.id )
      post :create, answer: {user_id: bob.id, description: "you want to do this and that"}, question_id: alice_question1.id

      item = NewsfeedItem.first
      expect(NewsfeedItem.from_users_followed_by(alice)).to match_array([item])
    end
  end

  describe "POST vote" do
    
    let!(:alice) {Fabricate(:user, user_group: "nonprofit")}
    let!(:alice_question1) {Fabricate(:question, user_id: alice.id)}
    let!(:bob) {Fabricate(:user, user_group: "volunteer")}
    let!(:bob_answer1) {Fabricate(:answer, question_id: alice_question1.id, user_id: bob.id)}
    let!(:cat) {Fabricate(:user, user_group: "volunteer")}
    

    before(:each) do
      request.env["HTTP_REFERER"] = "/questions/1" unless request.nil? or request.env.nil?
    end

    it "redirects user to the sign in page if not logged in" do
      post :vote, vote: true, id: bob_answer1.id, question_id: alice_question1.id

      expect(response).to redirect_to(sign_in_path)
    end

    it "returns the user back to the question object" do
      set_current_user(cat)
      post :vote, vote: true, id: bob_answer1.id, question_id: alice_question1.id

      expect(response).to redirect_to(question_path(alice_question1.id))
    end

    it "creates a vote" do
      set_current_user(cat)
      post :vote, vote: true, id: bob_answer1.id, question_id: alice_question1.id

      expect(Vote.count).to eq(1)
    end

    it "creates an up vote" do
      set_current_user(cat)
      post :vote, vote: true, id: bob_answer1.id, question_id: alice_question1.id

      expect(Vote.first.vote).to eq(true)
    end

    it "creates a down vote" do
      set_current_user(cat)
      post :vote, vote: false, id: bob_answer1.id, question_id: alice_question1.id

      expect(Vote.first.vote).to eq(false)
    end

    it "assigns a vote to an answer" do
      set_current_user(cat)
      post :vote, vote: true, id: bob_answer1.id, question_id: alice_question1.id

      expect(Vote.first.voteable_id).to eq(bob_answer1.id)
      expect(Vote.first.voteable_type).to eq("Answer")
    end

    it "assigns a vote to a user" do
      set_current_user(cat)
      post :vote, vote: true, id: bob_answer1.id, question_id: alice_question1.id

      expect(Vote.first.voter).to eq(cat)
    end

    it "does not let the user vote on his/her own answer" do
      set_current_user(bob)
      post :vote, vote: true, id: bob_answer1.id, question_id: alice_question1.id

      expect(Vote.count).to eq(0)
    end

    it "flashes a notice letting that user know that the vote has been counted" do
      set_current_user(cat)
      post :vote, vote: true, id: bob_answer1.id, question_id: alice_question1.id

      expect(flash[:success]).to eq("Thank you for voting.")
    end

    it "only lets the user vote once" do
      set_current_user(cat)
      Fabricate(:vote, vote: true, user_id: cat.id, voteable: alice_question1)
      post :vote, vote: true, id: bob_answer1.id, question_id: alice_question1.id

      expect(Vote.count).to eq(1)
    end
  end
end
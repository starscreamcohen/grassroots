require 'spec_helper'

describe QuestionsController, :type => :controller do
  describe "GET index" do

    let!(:alice) {Fabricate(:user, user_group: "nonprofit")}
    let!(:alice_question1) {Fabricate(:question, user_id: alice.id)}
    let!(:alice_question2) {Fabricate(:question, user_id: alice.id)}

    it "renders the index template" do
      get :index

      expect(response).to render_template(:index)
    end

    it "sets @questions" do
      alice = Fabricate(:user, user_group: "nonprofit")
      get :index

      expect(assigns(:questions)).to match_array([alice_question1, alice_question2])
    end
  end

  describe "GET show" do

    let!(:alice) {Fabricate(:user, user_group: "nonprofit")}
    let!(:alice_question1) {Fabricate(:question, user_id: alice.id)}

    it "renders the show template" do
      get :show, id: alice_question1.id

      expect(response).to render_template(:show)
    end

    it "sets @question" do
      get :show, id: alice_question1.id

      expect(assigns(:question)).to be_instance_of(Question)
    end

    it "sets @comment" do
      get :show, id: alice_question1.id

      expect(assigns(:comment)).to be_instance_of(Comment)
    end

    it "sets @answers" do
      bob = Fabricate(:user, user_group: "volunteer")
      bob_answer = Fabricate(:answer, description: "You need to do this......", question_id: alice_question1.id, user_id: bob.id)
      get :show, id: alice_question1

      expect(assigns(:answers)).to match_array([bob_answer])
    end

    it "shows the answers comments" do
      bob = Fabricate(:user, user_group: "volunteer")
      bob_answer = Fabricate(:answer, description: "You need to do this......", question_id: alice_question1.id, user_id: bob.id)
      alice_comment = Comment.create(user_id: alice.id, content: "thank you!", commentable: bob_answer)
      get :show, id: alice_question1

      expect(bob_answer.comments).to match_array([alice_comment])
    end

    it "shows the questions comments" do
      bob = Fabricate(:user, user_group: "volunteer")
      bob_comment = Comment.create(user_id: bob.id, content: "can you clarify your question?", commentable: alice_question1)
      get :show, id: alice_question1

      expect(alice_question1.comments).to match_array([bob_comment])
    end

    it "shows numerous comments on their respective answers" do
      bob = Fabricate(:user, user_group: "volunteer")
      bob_answer = Fabricate(:answer, description: "You need to do this......", question_id: alice_question1.id, user_id: bob.id)
      cat = Fabricate(:user, user_group: "volunteer")
      cat_answer = Fabricate(:answer, description: "I think you should do this......", question_id: alice_question1.id, user_id: cat.id)
      alice_comment = Comment.create(user_id: alice.id, content: "thank you!", commentable: bob_answer)
      alice_comment2 = Comment.create(user_id: alice.id, content: "that was a good point", commentable: cat_answer)
      get :show, id: alice_question1

      expect(cat_answer.comments).to match_array([alice_comment2])
    end
  end

  describe "GET new" do
    let!(:alice) {Fabricate(:user, user_group: "nonprofit")}

    it "renders the new template for creating a project" do
      get :new
      expect(response).to render_template(:new)
    end

    it "sets @question" do
      get :new
      expect(assigns(:question)).to be_instance_of(Question)
    end
  end

  describe "POST create" do
    let!(:alice) {Fabricate(:user, user_group: "nonprofit")}
    let!(:bob) {Fabricate(:user, user_group: "volunteer")}
    let!(:uncategorized) {Fabricate(:category, name: "Uncategorized")}
    let!(:web_development) {Fabricate(:category, name: "Web Development")}
    let!(:graphic_design) {Fabricate(:category, name: "Graphic Design")}
    let!(:social_media) {Fabricate(:category, name: "Social Media")}

    before do
      set_current_user(alice)
    end

    it "redirects to the questions index" do
      post :create, question: {title: "WordPress?", description: "Should I use wordpress, yo?"}

      expect(response).to redirect_to(questions_path)
    end

    it "creates a question" do
      post :create, question: {title: "WordPress?", description: "Should I use wordpress, yo?"}

      expect(Question.count).to eq(1)
    end

    it "creates a question associated with a user" do
      post :create, question: {title: "WordPress?", description: "Should I use wordpress, yo?"}

      expect(Question.first.author).to eq(alice)
    end
    it "creates a question associated with uncategorized category when unselected" do
      post :create, question: {title: "WordPress?", description: "Should I use wordpress, yo?"}

      question = Question.first
      expect(question.categories).to eq([uncategorized])
    end

    it "creates a question associated with a category when selected" do
      post :create, question: {title: "WordPress?", description: "Should I use wordpress, yo?", category_ids: [web_development.id]}

      question = Question.first
      expect(question.categories).to eq([web_development])
    end

    it "creates a question associated with more than one category" do
      post :create, question: {title: "WordPress?", description: "Should I use wordpress, yo?", category_ids: [web_development.id, social_media.id]}

      question = Question.first
      expect(question.categories).to eq([web_development, social_media])
    end

    it "publishes this as activity on the newsfeed of others who follow the current user" do
      Fabricate(:relationship, follower_id: bob.id, leader_id: alice.id )
      post :create, question: {title: "WordPress?", description: "Should I use wordpress, yo?", category_ids: [web_development.id, social_media.id]}

      item = NewsfeedItem.first
      expect(NewsfeedItem.from_users_followed_by(bob)).to match_array([item])
    end
  end

  describe "GET edit" do
    let!(:alice) {Fabricate(:user, user_group: "nonprofit")}
    let!(:alice_question1) {Fabricate(:question, user_id: alice.id)}

    it "renders the edit template" do
      get :edit, id: alice_question1.id

      expect(response).to render_template(:edit)
    end

    it "sets @question" do
      get :edit, id: alice_question1.id

      expect(assigns(:question)).to be_instance_of(Question)
    end
  end

  describe "PATCH update" do
    let!(:alice) {Fabricate(:user, user_group: "nonprofit")}
    let!(:alice_question1) {Fabricate(:question, user_id: alice.id, title: "PHP Advice")}

    it "redirects to the question show view" do
      patch :update, id: alice_question1.id, question: {title: "Ruby Advice"}

      expect(response).to redirect_to(question_path(alice_question1.id))
    end

    it "updates the question" do
      patch :update, id: alice_question1.id, question: {title: "Ruby Advice"}

      expect(alice_question1.reload.title).to eq("Ruby Advice")
    end
  end

  describe "POST vote" do
    let!(:bob) {Fabricate(:user, user_group: "volunteer")}
    let!(:bob_question1) {Fabricate(:question, user_id: bob.id)}
    let!(:alice) {Fabricate(:user, user_group: "nonprofit")}
    let!(:alice_question1) {Fabricate(:question, user_id: alice.id, title: "PHP Advice")}

    before(:each) do
      request.env["HTTP_REFERER"] = "/questions/2" unless request.nil? or request.env.nil?
    end

    it "redirects user to the sign in page if not logged in" do
      post :vote, vote: true, id: alice_question1.id
      expect(response).to redirect_to(sign_in_path)
    end

    it "returns the user back to the question object" do
      set_current_user(bob)
      post :vote, vote: true, id: alice_question1.id
      expect(response).to redirect_to(question_path(alice_question1.id))
    end

    it "creates a vote" do
      set_current_user(bob)
      post :vote, vote: true, id: alice_question1.id
      expect(Vote.count).to eq(1)
    end

    it "creates an up vote" do
      set_current_user(bob)
      post :vote, vote: true, id: alice_question1.id
      expect(Vote.first.vote).to eq(true)
    end

    it "creates a down vote" do
      set_current_user(bob)
      post :vote, vote: false, id: alice_question1.id
      expect(Vote.first.vote).to eq(false)
    end

    it "assigns a vote to a question" do
      set_current_user(bob)
      post :vote, vote: false, id: alice_question1.id
      expect(Vote.first.voteable_id).to eq(alice_question1.id)
      expect(Vote.first.voteable_type).to eq("Question")
    end

    it "assigns a vote to a user" do
      set_current_user(bob)
      post :vote, vote: false, id: alice_question1.id
      expect(Vote.first.user_id).to eq(bob.id)
    end

    it "does not let the user vote on his/her own question" do
      set_current_user(alice)
      post :vote, vote: false, id: alice_question1.id
      expect(Vote.count).to eq(0)
    end

    it "flashes a notice letting that user know that the vote has been counted" do
      set_current_user(bob)
      post :vote, vote: false, id: alice_question1.id
      expect(flash[:success]).to eq("Thank you for voting.")
    end

    it "only lets the user vote once" do
      set_current_user(bob)
      Fabricate(:vote, vote: true, user_id: bob.id, voteable: alice_question1)

      post :vote, vote: true, id: alice_question1.id
      expect(Vote.count).to eq(1)
    end
  end
end
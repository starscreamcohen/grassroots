require 'spec_helper'

describe CommentsController, :type => :controller do
  describe "POST create" do

    context "when commenting on a question" do

      let!(:alice) {Fabricate(:user, user_group: "nonprofit")}
      let!(:alice_question1) {Fabricate(:question, user_id: alice.id)}
      let!(:bob) {Fabricate(:user, user_group: "volunteer")}

      before(:each) do
        set_current_user(bob)
        request.env["HTTP_REFERER"] = "/questions/1" unless request.nil? or request.env.nil?
      end

      it "redirects user to the question show view when commenting on a question" do
        post :create, comment: {content: "this is a great question"}, question_id: alice_question1.id

        expect(response).to redirect_to(question_path(alice_question1.id))
      end

      it "creates a comment" do
        post :create, comment: {content: "this is a great question"}, question_id: alice_question1.id

        expect(Comment.count).to eq(1)
      end

      it "creates a comment associated with an author" do
        post :create, comment: {content: "this is a great question"}, question_id: alice_question1.id

        expect(Comment.first.author).to eq(bob)
      end

      it "creates a comment associated with a question when commenting on a question" do
        post :create, comment: {content: "this is a great question"}, question_id: alice_question1.id

        expect(Comment.first.commentable_type).to eq('Question')
      end

      it "sets the content attribute of the comment with the submitted parameters" do
        post :create, comment: {content: "this is a great question"}, question_id: alice_question1.id

        expect(Comment.first.content).to eq("this is a great question")
      end

      it "does not create a comment with empty content" do
        post :create, comment: {content: ""}, question_id: alice_question1.id

        expect(Comment.count).to eq(0)
      end
    end

    context "when commenting on an answer" do
      let!(:alice) {Fabricate(:user, user_group: "nonprofit")}
      let!(:alice_question1) {Fabricate(:question, user_id: alice.id)}
      let!(:bob) {Fabricate(:user, user_group: "volunteer")}
      let!(:bob_answer) {Fabricate(:answer, user_id: alice.id, question_id: alice_question1.id)}

      before do
        set_current_user(alice)
        request.env["HTTP_REFERER"] = "/questions/1" unless request.nil? or request.env.nil?
      end

      it "redirects user to the answer show view when commenting on an answer" do
        post :create, comment: {content: "this is a great question"}, question_id: alice_question1.id, answer_id: bob_answer.id
        
        expect(response).to redirect_to(question_path(alice_question1))
      end

      it "creates a comment associated with a answer when commenting on a answer" do
        post :create, comment: {content: "this is a great question"}, question_id: alice_question1.id, answer_id: bob_answer.id

        expect(Comment.first.commentable).to eq(bob_answer)
      end
    end

    context "when commenting on newsfeed item" do
      let!(:huggey_bears) {Fabricate(:organization, cause: "animals")}
      let!(:alice) {Fabricate(:organization_administrator, first_name: "Alice", organization_id: huggey_bears.id, user_group: "nonprofit")}

      before(:each) do
        set_current_user(alice)
        request.env["HTTP_REFERER"] = "/newsfeed_items" unless request.nil? or request.env.nil?
      end

      it "redirects the user to the newsfeed index" do
        project = Fabricate(:project, organization_id: huggey_bears.id)
        newsfeed_item = NewsfeedItem.create(user_id: alice.id)
        project.newsfeed_items << newsfeed_item
        post :create, comment: {content: "I can't wait to join this project."}, newsfeed_item_id: newsfeed_item.id

        expect(response).to redirect_to(newsfeed_items_path)
      end

      it "creates a comment associated with a newsfeed item" do
        project = Fabricate(:project, organization_id: huggey_bears.id)
        newsfeed_item = NewsfeedItem.create(user_id: alice.id)
        project.newsfeed_items << newsfeed_item
        post :create, comment: {content: "I can't wait to join this project."}, newsfeed_item_id: newsfeed_item.id

        expect(Comment.first.commentable).to eq(newsfeed_item)
      end
    end
  end
  describe "POST vote" do
    context "when voting on a comment of a question" do
      let!(:bob) {Fabricate(:user, user_group: "volunteer")}
      let!(:bob_question1) {Fabricate(:question, user_id: bob.id)}
      let!(:alice) {Fabricate(:user, user_group: "nonprofit")}
      let!(:alice_comment1) {Fabricate(:comment, commentable: bob_question1, user_id: alice.id, content: "this is a great question")}

      before(:each) do
        request.env["HTTP_REFERER"] = "/questions/1" unless request.nil? or request.env.nil?
      end

      it "redirects user to the sign in page if not logged in" do
        post :vote, vote: true, id: alice_comment1.id, question_id: bob_question1.id

        expect(response).to redirect_to(sign_in_path)
      end

      it "returns the user back to the question object" do
        set_current_user(bob)
        post :vote, vote: true, id: alice_comment1.id, question_id: bob_question1.id

        expect(response).to redirect_to(question_path(bob_question1.id))
      end

      it "creates a vote" do
        set_current_user(bob)
        post :vote, vote: true, id: alice_comment1.id, question_id: bob_question1.id
        expect(Vote.count).to eq(1)
      end

      it "creates an up vote" do
        set_current_user(bob)
        post :vote, vote: true, id: alice_comment1.id, question_id: bob_question1.id
        expect(Vote.first.vote).to eq(true)
      end

      it "creates a down vote" do
        set_current_user(bob)
        post :vote, vote: false, id: alice_comment1.id, question_id: bob_question1.id
        expect(Vote.first.vote).to eq(false)
      end

      it "assigns a vote to a comment of a question" do
        set_current_user(bob)
        post :vote, vote: true, id: alice_comment1.id, question_id: bob_question1.id
        expect(Vote.first.voteable_id).to eq(alice_comment1.id)
        expect(Vote.first.voteable_type).to eq("Comment")
      end

      it "assigns a vote to a user" do
        set_current_user(bob)
        post :vote, vote: true, id: alice_comment1.id, question_id: bob_question1.id
        expect(Vote.first.user_id).to eq(bob.id)
      end

      it "does not let the user vote on his/her own question" do
        set_current_user(alice)
        post :vote, vote: true, id: alice_comment1.id, question_id: bob_question1.id
        expect(Vote.count).to eq(0)
      end

      it "flashes a notice letting that user know that the vote has been counted" do
        set_current_user(bob)
        post :vote, vote: true, id: alice_comment1.id, question_id: bob_question1.id
        expect(flash[:success]).to eq("Thank you for voting.")
      end

      it "only lets the user vote once" do
        set_current_user(bob)
        Fabricate(:vote, vote: true, user_id: bob.id, voteable: alice_comment1)

        post :vote, vote: true, id: alice_comment1.id, question_id: bob_question1.id
        expect(Vote.count).to eq(1)
      end
    end
    context "when voting on a comment of an answer" do
      let!(:bob) {Fabricate(:user, user_group: "volunteer")}
      let!(:bob_question1) {Fabricate(:question, user_id: bob.id)}
      let!(:alice) {Fabricate(:user, user_group: "nonprofit")}
      let!(:alice_answer1) {Fabricate(:answer, question_id: bob_question1.id, user_id: alice.id)}
      let!(:bob_comment1) {Fabricate(:comment, commentable: alice_answer1, user_id: bob.id, content: "this is a great answer")}

      before(:each) do
        request.env["HTTP_REFERER"] = "/questions/1" unless request.nil? or request.env.nil?
      end

      it "redirects user to the sign in page if not logged in" do
        post :vote, vote: true, id: bob_comment1.id, answer_id: alice_answer1.id, question_id: bob_question1.id

        expect(response).to redirect_to(sign_in_path)
      end

      it "returns the user back to the question object" do
        set_current_user(alice)
        post :vote, vote: true, id: bob_comment1.id, answer_id: alice_answer1.id, question_id: bob_question1.id

        expect(response).to redirect_to(question_path(bob_question1.id))
      end

      it "creates a vote" do
        set_current_user(alice)
        post :vote, vote: true, id: bob_comment1.id, answer_id: alice_answer1.id, question_id: bob_question1.id

        expect(Vote.count).to eq(1)
      end

      it "creates an up vote" do
        set_current_user(alice)
        post :vote, vote: true, id: bob_comment1.id, answer_id: alice_answer1.id, question_id: bob_question1.id

        expect(Vote.first.vote).to eq(true)
      end

      it "creates a down vote" do
        set_current_user(alice)
        post :vote, vote: false, id: bob_comment1.id, answer_id: alice_answer1.id, question_id: bob_question1.id

        expect(Vote.first.vote).to eq(false)
      end

      it "assigns a vote to a comment of a answer" do
        set_current_user(alice)
        post :vote, vote: true, id: bob_comment1.id, answer_id: alice_answer1.id, question_id: bob_question1.id

        expect(Vote.first.voteable_id).to eq(bob_comment1.id)
        expect(Vote.first.voteable_type).to eq("Comment")
      end

      it "assigns a vote to a user" do
        set_current_user(alice)
        post :vote, vote: true, id: bob_comment1.id, answer_id: alice_answer1.id, question_id: bob_question1.id

        expect(Vote.first.voter).to eq(alice)
      end

      it "does not let the user vote on his/her own question" do
        set_current_user(bob)
        post :vote, vote: true, id: bob_comment1.id, answer_id: alice_answer1.id, question_id: bob_question1.id

        expect(Vote.count).to eq(0)
      end

      it "flashes a notice letting that user know that the vote has been counted" do
        set_current_user(alice)
        post :vote, vote: true, id: bob_comment1.id, answer_id: alice_answer1.id, question_id: bob_question1.id

        expect(flash[:success]).to eq("Thank you for voting.")
      end

      it "only lets the user vote once" do
        set_current_user(alice)
        Fabricate(:vote, vote: true, user_id: alice.id, voteable: bob_comment1)

        post :vote, vote: true, id: bob_comment1.id, answer_id: alice_answer1.id, question_id: bob_question1.id
        expect(Vote.count).to eq(1)
      end
    end
  end
end
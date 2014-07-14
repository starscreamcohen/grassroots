class CommentsController < ApplicationController
  before_action :authorize, only: [:create, :vote]
  before_action :find_question, only: [:create]
  before_action :find_answer, only: [:create]
  before_action :find_newsfeed_item, only: [:create]

  def create
    if commenting_on_an_answer?
      create_a_comment_on_questions_answer
    elsif commenting_on_question?
      create_a_comment_on_question
    else
      create_a_comment_on_newsfeed_item
    end
    redirect_to :back
  end

  def vote
    @comment = Comment.find(params[:id])
    if @comment.author.id == current_user.id
      flash[:error] = "You cannot vote on your own comment."
    else
      vote = Vote.create(voteable: @comment, voter: current_user, vote: params[:vote]) 
      vote.valid? ? flash[:success] = "Thank you for voting." : flash[:error] = "You can only vote once on this comment."
    end
    redirect_to :back
  end

private

  def find_question
    @question = Question.find(params[:question_id]) if params[:question_id]
  end
  
  def find_answer
    @answer = Answer.find(params[:answer_id]) if params[:answer_id]
  end

  def find_newsfeed_item
    @newsfeed_item = NewsfeedItem.find(params[:newsfeed_item_id]) if params[:newsfeed_item_id]
  end

  def commenting_on_an_answer?
    @question && @answer
  end

  def commenting_on_question?
    @question
  end

  def create_a_comment_on_questions_answer
    @comment = Comment.create(commentable: @answer, user_id: current_user.id, content: params[:comment][:content])
  end

  def create_a_comment_on_question
    @comment = Comment.create(commentable: @question, user_id: current_user.id, content: params[:comment][:content])
  end

  def create_a_comment_on_newsfeed_item
    @comment = Comment.create(commentable: @newsfeed_item, user_id: current_user.id, content: params[:comment][:content])
  end

end
class AnswersController < ApplicationController
  before_action :authorize, only: [:create, :vote, :comment]

  def create
    posts_an_answer_to_question
    makes_answer_a_newsfeed_item(@answer)
    redirect_to :back
  end

  def vote
    @answer = Answer.find(params[:id])
    @question = Question.find(params[:question_id])

    if @answer.user_id == current_user.id
      flash[:error] = "You cannot vote on your own answer."
    else
      vote = Vote.create(voteable: @answer, user_id: current_user.id, vote: params[:vote]) 
      vote.valid? ? flash[:success] = "Thank you for voting." : flash[:error] = "You can only vote once on this answer."
    end

    redirect_to :back
  end

private

  def answer_params
    params.require(:answer).permit(:description)    
  end

  def posts_an_answer_to_question
    @answer = Answer.new(answer_params)
    @answer.author = current_user
    @answer.question_id = params[:question_id]
    @answer.save
  end

  def makes_answer_a_newsfeed_item(answer)
    newsfeed_item = NewsfeedItem.create(user_id: current_user.id)
    answer.newsfeed_items << newsfeed_item
  end
end
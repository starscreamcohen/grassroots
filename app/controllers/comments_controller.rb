class CommentsController < ApplicationController
  def create
    if params[:question_id] && params[:answer_id]
      @answer = Answer.find_by(params[:question_id])
      @comment = Comment.new(params.require(:comment).permit(:content))
      @comment = @answer.comments.build(params.require(:comment).permit(:content))
      @comment.author = current_user
      @comment.save
      redirect_to :back
    else
      @question = Question.find(params[:question_id])
      @comment = Comment.new(params.require(:comment).permit(:content))
      @comment = @question.comments.build(params.require(:comment).permit(:content))
      @comment.author = current_user
      @comment.save
      redirect_to :back
    end
  end

private

end
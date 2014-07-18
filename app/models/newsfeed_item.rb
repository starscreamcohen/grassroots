class NewsfeedItem < ActiveRecord::Base
  belongs_to :author, class_name: 'User', foreign_key: 'user_id'
  belongs_to :newsfeedable, polymorphic: :true  
  has_many :comments, as: :commentable

  def self.from_users_followed_by(a_user)
    relevent_items = a_user.following_relationships.map do |leader|
      following = User.find(leader.leader_id)
      following.newsfeed_items
    end
    relevent_items << a_user.newsfeed_items
    relevent_items.flatten
  end

  def question_categories
    question = Question.find(self.newsfeedable_id)
    question.categories.map(&:name).flatten
  end

  def answer_categories
    answer = Answer.find(self.newsfeedable_id)
    question = Question.find(answer.question_id)
    question.categories.map(&:name).flatten
  end

  def title_of_answers_question
    answer = Answer.find(self.newsfeedable_id)
    question = Question.find(answer.question_id)
    question.title
  end
end
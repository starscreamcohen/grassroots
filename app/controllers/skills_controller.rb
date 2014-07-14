class SkillsController < ApplicationController
  def create
    if Skill.where(name: params[:skill][:name]) != []
      skill = Skill.where(name: params[:skill][:name]).first
      current_user.skills << skill

    else
      skill = Skill.create(name: params[:skill][:name]) if params[:skill][:name]
      current_user.skills << skill if params[:skill][:name]
    end
    redirect_to :back
  end
end
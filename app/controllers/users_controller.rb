class UsersController < ApplicationController
  before_action :find_user, only: [:show]
  before_action :find_open_applications, only: [:show]
  before_action :find_in_production_projects, only: [:show]
  before_action :find_projects_with_work_submitted, only: [:show]
  before_action :find_completed_projects, only: [:show]
  

  before_action :find_open_projects_params_tab, only: [:show]
  before_action :find_in_production_projects_params_tab, only: [:show]
  before_action :find_projects_pending_approval_params_tab, only: [:show]
  before_action :find_completed_projects_params_tab, only: [:show]
  before_action :find_unfinished_projects_params_tab, only: [:show]
  before_action :find_expired_projects_params_tab, only: [:show]

  def index
    @users = User.all
  end

  def show
    @relationships = @user.following_relationships
    @following_relationship = Relationship.where(follower: current_user, leader: @user).first
    respond_to do |format|
      format.html do
      end
      format.js
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      AppMailer.delay.send_welcome_email(@user.id)
      session[:user_id] = @user.id
      redirect_to user_path(@user.id)
    else
      flash[:notice] = "Please try again."
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
    @skill = Skill.new
  end

  def update
    @user = User.find(params[:id])
    organization = Organization.find_by(name: params[:user][:organization_name_box])
    if an_unaffiliated_nonprofit_user_updates_profile?(organization)
      @user.update_columns(user_params.merge!(organization_administrator: true))
      uploading_profile_avatar?
      earns_profile_completion_badge?
      redirect_to new_organization_admin_organization_path
    elsif a_nonprofit_staff_member_updates_profile?(organization)
      @user.update_columns(user_params)
      uploading_profile_avatar?
      earns_profile_completion_badge?
      flash[:notice] = "You have updated your profile successfully."
      redirect_to user_path(@user.id)
    elsif a_volunteer_updates_profile?
      @user.update_columns(user_params)
      uploading_profile_avatar?
      earns_profile_completion_badge?
      flash[:notice] = "You have updated your profile successfully."
      redirect_to user_path(@user.id)
    else
      flash[:error] = "Please try again."
      render :edit
    end
  end

  def remove
    user = User.find(params[:id])
    organization = Organization.find(user.organization_id)
    user.update_columns(organization_id: nil)
    redirect_to organization_path(organization.id)
  end

  def search
    filter = {interests: params[:interests]}  if params[:interests]
    filter = {state_abbreviation: params[:state_abbreviation]} if params[:state_abbreviation]
    filter = {city: params[:city]} if params[:city]
    filter = {position: params[:position]} if params[:position]
    
    if filter != nil
      @results = User.where(filter).to_a
      @results.sort! {|x,y| x.last_name <=> y.last_name }
    end 

    if params[:skills]
      skill = Skill.where(name: params[:skills]).first
      @results = skill.users
    end
  end

private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, 
      :organization_id, :bio, :interests, :position, :user_group, 
      :contact_reason, :state_abbreviation, :city)
  end

  def uploading_profile_avatar?
    if params[:user][:avatar]
      @user.avatar = params[:user][:avatar]
      @user.avatar.save
    end
  end

  def an_unaffiliated_nonprofit_user_updates_profile?(organization)
    organization.nil? && current_user.user_group == "nonprofit"
  end
 
  def a_nonprofit_staff_member_updates_profile?(organization)
    current_user.user_group == "nonprofit" && organization
  end
 
  def a_volunteer_updates_profile?
    current_user.user_group == "volunteer"
  end

  def earns_profile_completion_badge?
    if @user.update_profile_progress == 100
      badge = Badge.find_by(name: "100% User Profile Completion")
      @user.badges << badge unless @user.awarded?(badge)
      @newsfeed_item = NewsfeedItem.create(user_id: current_user.id)
      badge.newsfeed_items << @newsfeed_item
    end
  end

  def find_user
    @user = User.find(params[:id])
  end

  def find_open_applications
    @applications = @user.projects_with_open_applications
  end

  def find_in_production_projects
    @projects_in_production = @user.projects_in_production
  end

  def find_projects_with_work_submitted
    @submitted_work = @user.submitted_work
  end

  def find_completed_projects
    @completed_projects = @user.completed_projects
  end

  def find_open_projects_params_tab
    @open_params = params[:tab] == 'open'
  end

  def find_in_production_projects_params_tab
    @production_params = params[:tab] == 'in production' 
  end

  def find_projects_pending_approval_params_tab
    @work_submitted_params = params[:tab] == 'pending approval'
  end

  def find_completed_projects_params_tab
    @completed_params = params[:tab] == 'completed' 
  end

  def find_unfinished_projects_params_tab
    @unifinished_params = params[:tab] == 'unfinished' 
  end

  def find_expired_projects_params_tab
    @expired_params = params[:tab] == 'expired' 
  end
end
class OrganizationsController < ApplicationController
  
  before_action :find_organization, only: [:show]
  before_action :find_open_projects, only: [:show]
  before_action :find_in_production_projects, only: [:show]
  before_action :find_projects_with_work_submitted, only: [:show]
  before_action :find_completed_projects, only: [:show]
  before_action :find_unfinished_projects, only: [:show]
  before_action :find_expired_projects, only: [:show]
  
  before_action :find_open_projects_params_tab, only: [:show]
  before_action :find_in_production_projects_params_tab, only: [:show]
  before_action :find_projects_pending_approval_params_tab, only: [:show]
  before_action :find_completed_projects_params_tab, only: [:show]
  before_action :find_unfinished_projects_params_tab, only: [:show]
  before_action :find_expired_projects_params_tab, only: [:show]

  
  def show
    @organization = Organization.find(params[:id])

    respond_to do |format|
      format.html do
      end
      format.js
    end
  end

  def index
    @organizations = Organization.all
  end

  def search
    filter = {cause: params[:cause]} if params[:cause]
    
    if filter != nil
      @results = Organization.where(filter).to_a
      @results.sort! {|x,y| x.name <=> y.name }
    else
      @results = Organization.search_by_name(params[:search_term])
    end 
  end

private

  def organization_params
    params.require(:organization).permit(:name, :date_of_incorporation, 
      :ein, :street1, :street2, :city, :state_abbreviation, :zip, :cause, 
      :contact_number, :contact_email, :mission_statement, :goal, :user_id)
  end

  def find_organization
    @organization = Organization.find(params[:id])
  end

  def find_open_projects
    @open_projects = @organization.open_projects
  end

  def find_in_production_projects
    @in_production_projects = @organization.in_production_projects
  end

  def find_projects_with_work_submitted
    @projects_with_work_submitted = @organization.projects_with_work_submitted
  end

  def find_completed_projects
    @completed_projects = @organization.completed_projects
  end

  def find_unfinished_projects
    @unfinished_projects = @organization.unfinished_projects
  end

  def find_expired_projects
    @expired_projects = @organization.expired_projects
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
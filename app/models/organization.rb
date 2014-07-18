class Organization < ActiveRecord::Base
  belongs_to :organization_administrator, foreign_key: 'user_id', class_name: 'User'  
  has_many :projects
  has_many :users

  has_attachment :logo, accept: [:jpg, :png, :gif]

  def open_projects
    projects.select do |member|
      member.state == "open" && member.deadline > Date.today
    end
  end

  def in_production_projects
    active_contracts = organization_administrator.delegated_projects.where(active: true, dropped_out: nil, complete: nil, incomplete: nil, work_submitted: false).to_a
    projects_in_production = active_contracts.map do |member|
      Project.find(member.project_id)
    end
    projects_in_production.sort
  end

  def projects_with_work_submitted
    contracts_reflecting_work_submitted = organization_administrator.delegated_projects.where(active: true, work_submitted: true).to_a
    contracts_reflecting_work_submitted.map do |member|
      Project.find(member.project_id)
    end
  end

  def completed_projects
    completed_contracts = organization_administrator.delegated_projects.where(active: false, work_submitted: true, complete: true, incomplete: false).to_a
    completed_contracts.map do |member|
      Project.find(member.project_id)
    end
  end

  def unfinished_projects
    unfinished_contracts = organization_administrator.delegated_projects.where(incomplete: true).to_a
    unfinished_contracts.map do |member|
      Project.find(member.project_id)
    end
  end

  def expired_projects
    projects.select do |member|
      member.deadline < Date.today
    end
  end

  def self.search_by_name(search_term)
    return [] if search_term.blank?
    where("name LIKE ?", "%#{search_term}%")
  end
end
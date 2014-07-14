class OrganizationAdmin::ProjectsController < OrganizationAdminController
  before_action :find_organization, only: [:create]
  
  def new
    @project = Project.new(organization_id: params[:organization_id])
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      @project.update_columns(state: "open", causes: @organization.cause)
      creates_a_newsfeed_item_for_the_project(@project)
      flash[:notice] = "You successfully created a project"
      redirect_to project_path(@project.id)
    else
      render :new
    end
  end

  def edit
    @project = Project.find(params[:id])  
  end

  def update
    @project = Project.find(params[:id])
    @project.update(project_params)
    flash[:success] = "You updated your project"
    redirect_to project_path(@project.id)
  end

private

  def project_params
    params.require(:project).permit(:title, :organization_id, :user_id, :description, :skills, :deadline)
  end

  def creates_a_newsfeed_item_for_the_project(project)
    @newsfeed_item = NewsfeedItem.create(user_id: current_user.id)
    project.newsfeed_items << @newsfeed_item
  end

  def find_organization
    @organization = Organization.find_by(params[:id])
  end
end
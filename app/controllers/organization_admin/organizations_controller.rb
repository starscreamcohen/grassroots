class OrganizationAdmin::OrganizationsController < OrganizationAdminController
  before_action :find_organization, only: [:update, :edit]
  
  def new
    @organization = Organization.new
  end

  def edit; end

  def update
    @organization.update_columns(organization_params)
    uploading_logo?(@organization)
    flash[:notice] = "You have updated your organization's profile."
    redirect_to organization_path(@organization.id)
  end

  def create
    @organization = Organization.new(organization_params.merge!(user_id: current_user.id))
    @organization.save
    current_user.update_columns(organization_id: @organization.id)
    flash[:success] = "You created your organization."
    redirect_to organization_path(@organization.id)
  end

private

  def organization_params
    params.require(:organization).permit(:name, :date_of_incorporation, 
      :ein, :street1, :street2, :city, :state_abbreviation, :zip, :cause, 
      :contact_number, :contact_email, :mission_statement, :goal, :user_id)
  end

  def uploading_logo?(a_organization)
    if params[:organization][:logo]
      a_organization.logo = params[:organization][:logo]
      a_organization.logo.save
    end
  end

  def find_organization
    @organization = Organization.find(params[:id])
  end
end
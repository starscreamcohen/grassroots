class OrganizationAdmin::OrganizationsController < OrganizationAdminController
  def edit
    @organization = Organization.find(params[:id])
  end

  def update
    organization = Organization.find(params[:id])
    organization.update_columns(organization_params)
    flash[:notice] = "You have updated your organization's profile."
    redirect_to organization_path(organization.id)
  end

private

  def organization_params
    params.require(:organization).permit(:name, :date_of_incorporation, 
      :ein, :street1, :street2, :city, :state_abbreviation, :zip, :cause, 
      :contact_number, :contact_email, :mission_statement, :goal, :user_id)
  end
end
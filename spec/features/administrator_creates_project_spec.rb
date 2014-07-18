require 'spec_helper'

feature 'Creating a project' do 
  scenario "Administrator of an organization signs in to create a project" do
    huggey_bears = Organization.create(name: "Huggey Bear Land", cause: "Animal Rights", ruling_year: 1998, 
      mission_statement: "We want to give everyone a huggey bear in their sad times", guidestar_membership: nil, 
      ein: "192512653-6", street1: "2998 Hansen Heights", street2: nil, city: "New York", 
      state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
      budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
      goal: "We want 1 out of every 5 Americans to have a huggey bear.")
    alice = User.create(organization_id: 1, first_name: "Alice", last_name: "Smith", email: "alice@huggey_bear.org", 
      interests: "Animal Rights", street1: nil, street2: nil, 
      city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
      organization_staff: nil, volunteer: nil, position: "Executive Director", password: "password", user_group: "nonprofit")
    huggey_bears.update_columns(user_id: 1)

    user_signs_in(alice)
    expect(page).to have_content("You are logged in!")
    visit new_organization_admin_project_path
    
    fills_out_project_form
    expect(page).to have_text("You successfully created a project")
    #expect(find(:xpath, "//ul//li[contains(.,'href=/organizations/#{organization.id}')"Open #{alice.open_projects.count}"].value).to eq("1")
  end

  def fills_out_project_form
    #expect(page).to have_select('project_skills', selected: "Web Development")
    #find_field('project_skills').find('option[Web Development]').text
    find("#project_deadline_2i").find(:xpath,"./option[contains(.,'October')]").selected?
    find("#project_deadline_3i").find(:xpath,"./option[contains(.,'15')]").selected?
    find("#project_deadline_1i").find(:xpath,"./option[contains(.,'2014')]").selected?
    fill_in "project[estimated_hours]", with: "25"
    fill_in "project[title]", with: "WordPress Help"
    fill_in "project[description]", with: "I need a word press website."
    find(:xpath, "//input[@id='project_organization_id']").set "1"
    click_button 'Create'
  end
end
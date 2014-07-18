require 'spec_helper'

feature 'User removes another user' do
  let!(:huggey_bears) {Fabricate(:organization, name: "Huggey Bear Land", cause: "Animal Rights", ruling_year: 1998, 
    mission_statement: "We want to give everyone a huggey bear in their sad times", guidestar_membership: nil, 
    ein: "192512653-6", street1: "2998 Hansen Heights", street2: nil, city: "New York", 
    state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
    budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
    goal: "We want 1 out of every 5 Americans to have a huggey bear.")}

  let!(:alice) {Fabricate(:user, organization_id: 1, first_name: "Alice", last_name: "Smith", email: "alice@huggey_bear.org", 
    interests: "Animal Rights", street1: nil, street2: nil, 
    city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
    organization_staff: nil, volunteer: nil, position: "Executive Director", password: "password", user_group: "nonprofit")}
  let!(:bob) {Fabricate(:user, organization_id: 1, first_name: "Bob", last_name: "Adams", email: "bob@huggey_bear.org", 
    interests: "Animal Rights", street1: nil, street2: nil, 
    city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
    organization_staff: nil, volunteer: nil, position: "Intern", password: "password", user_group: "nonprofit")}
  let!(:catherine) {Fabricate(:user, organization_id: 1, first_name: "Catherine", last_name: "Hemingway", email: "cat@huggey_bear.org", 
    interests: "Animal Rights", street1: nil, street2: nil, 
    city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
    organization_staff: nil, volunteer: nil, position: "Program Manager", password: "password", user_group: "nonprofit")}

  scenario "Administrator removes a staff member from organization's profile" do
    huggey_bears.update_columns(user_id: 1)
    user_signs_in(alice)
    expect(page).to have_content("You are logged in!")

    visit organization_path(huggey_bears.id)
    click_on("Overview")
    expect(page).to have_content("Bob Adams")
    expect(page).to have_content("Catherine Hemingway")
    
    click_on("Bob Adams")
    click_on("Remove Staff")
    click_on("Overview")
    expect(page).to_not have_content("Bob Adams")
  end
end

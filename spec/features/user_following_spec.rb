require 'spec_helper'

feature 'User following' do 
  let!(:bob) {Fabricate(:user, first_name: "Bob", last_name: "Adams", 
    email: "bob@example.come", user_group: "volunteer")}

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

  scenario 'user follows and unfollows someone' do
    user_signs_in(bob)
    huggey_bears.update_columns(user_id: 2)
    visit organizations_path
    find("input[value='Animal Rights']").set(true)
    click_on("Search")

    click_on("#{huggey_bears.name}")
    click_on("#{alice.first_name} #{alice.last_name}")
    click_on("Follow")

    visit user_path(bob)
    expect(page).to have_content("#{alice.first_name} #{alice.last_name}")
    click_on("Unfollow")
    
    expect(page).to_not have_content("#{alice.first_name} #{alice.last_name}")

  end
end
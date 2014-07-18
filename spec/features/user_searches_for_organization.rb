require 'spec_helper'

feature 'User searches for an organization' do 

  let!(:huggey_bears) {Fabricate(:organization, name: "Huggey Bear Land", cause: "Animal Rights", ruling_year: 1998, 
    mission_statement: "We want to give everyone a huggey bear in their sad times", guidestar_membership: nil, 
    ein: "192512653-6", street1: "2998 Hansen Heights", street2: nil, city: "New York", 
    state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
    budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
    goal: "We want 1 out of every 5 Americans to have a huggey bear.")}

  let!(:amnesty_international) {Fabricate(:organization, name: "Amnesty International", cause: "Human Rights", ruling_year: 1912,
    mission_statement: "We want to see human rights spread across the globe -- chyea.", guidestar_membership: nil, 
    ein: "987931299-1", street1: "3293 Dunnit Hill", street2: nil, city: "New York", 
    state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
    budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
    goal: "Every year we want at least one thousand human rights activists released from prisons around the world.")}

  let!(:global_giving) {Fabricate(:organization, name: "Global Giving", cause: "Social Good", ruling_year: 2000, 
    mission_statement: "We make it rain on Nonprofits, erreday", guidestar_membership: nil, 
    ein: "222222222-2", street1: "2222 Rick Ross", street2: nil, city: "DC", 
    state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
    budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
    goal: "We want each of our nonprofit partners to raise at least $ 5,000.00 from our platform a year.")}

  let!(:the_bears) {Fabricate(:organization, name: "The Bears")}

  let!(:alice) {Fabricate(:user, organization_id: 1, first_name: "Alice", last_name: "Smith", email: "alice@huggey_bear.org", 
    interests: "Animal Rights", street1: nil, street2: nil, 
    city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
    organization_staff: nil, volunteer: nil, position: "Executive Director", password: "password", user_group: "nonprofit")}
  let!(:bob) {Fabricate(:user, organization_id: 2, first_name: "Bob", last_name: "Adams", email: "bob@amnesty.org", 
    interests: "Human Rights", street1: nil, street2: nil, 
    city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
    organization_staff: nil, volunteer: nil, position: "Executive Director", password: "password", user_group: "nonprofit")}
  let!(:catherine) {Fabricate(:user, organization_id: 3, first_name: "Catherine", last_name: "Hemingway", email: "cat@globalgiving.org", 
    interests: "Health", street1: nil, street2: nil, 
    city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
    organization_staff: nil, volunteer: nil, position: "Executive Director", password: "password", user_group: "nonprofit")}


  scenario "user logs in and searches for an organization by checking off the corresponding cause" do
    

    huggey_bears.update_columns(user_id: 1)
    amnesty_international.update_columns(user_id: 2)
    global_giving.update_columns(user_id: 3)

    john_doe = Fabricate(:user, user_group: "nonprofit")
    user_signs_in(john_doe)
    expect(page).to have_content("You are logged in!")

    visit organizations_path

    find("input[value='Human Rights']").set(true)
    click_on("Search")

    expect(page).to have_content("#{amnesty_international.name}")
    expect(page).to_not have_content("#{global_giving.name}")
    expect(page).to_not have_content("#{huggey_bears.name}")
  end

  scenario "user logs in and searches for an organization with a keyword search" do

    huggey_bears.update_columns(user_id: 1)
    amnesty_international.update_columns(user_id: 2)
    global_giving.update_columns(user_id: 3)

    john_doe = Fabricate(:user, user_group: "nonprofit")
    user_signs_in(john_doe)
    expect(page).to have_content("You are logged in!")

    visit organizations_path

    fill_in "search_term", with: "bear"
    click_on("Search")
    
    expect(page).to_not have_content("#{global_giving.name}")
    expect(page).to_not have_content("#{amnesty_international.name}")
    expect(page).to have_content("#{the_bears.name}")
    expect(page).to have_content("#{huggey_bears.name}")
  end
end
require 'spec_helper'

feature 'User searches for a project' do 
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

  scenario "user logs in and searches for a project based on his/her competency and checks the box" do
  

  word_press = Project.create(title: "Need WordPress Site", description: "I want a nice looking WordPress site for my nonprofit", 
    skills: "Web Development", causes: "animals", deadline: Date.today + 1.month, organization_id: huggey_bears.id, estimated_hours: 22, state: "open")
  pretty_logo = Project.create(title: "Elegant Logo", description: "I want a logo that reflects the strenght of the human spirit!", 
    skills: "Graphic Design", causes: "human rights", deadline: Date.today + 1.month, organization_id: amnesty_international.id, estimated_hours: 32, state: "open")
  social_media = Project.create(title: "Twitter Help", description: "I need someone to push out 10 tweets a day for me", 
    organization_id: global_giving.id, skills: "Social Media", causes: "social", deadline: Date.today + 1.month, estimated_hours: 11, state: "open")
  fundraising = Project.create(title: "Fundraising Help", description: "I need help fundraising my organization", 
    skills: "Fundraising", causes: "animals", deadline: Date.today + 1.month, organization_id: huggey_bears.id, estimated_hours: 22, state: "open")
  rails_app = Project.create(title: "Ruby on Rails Application", description: "I want robust, agile software to help ", 
    skills: "Web Development", causes: "animals", deadline: Date.today + 1.month, organization_id: amnesty_international.id, estimated_hours: 22, state: "open")
  nice_pages = Project.create(title: "Front-end Design", description: "I need someone to snaz up our current organization's pages", 
    organization_id: global_giving.id, skills: "Web Development", causes: "social", deadline: Date.today + 1.month, estimated_hours: 11, state: "open")
  facebook_help = Project.create(title: "Facebook assistance", description: "We need someone to help run a facebook campaign", 
    skills: "Fundraising", causes: "animals", deadline: Date.today + 1.month, organization_id: huggey_bears.id, estimated_hours: 22, state: "open")
  tax_assistance = Project.create(title: "Accounting Help", description: "We forgot to do our taxes. O well.....", 
    organization_id: global_giving.id, skills: "Accounting", causes: "social", deadline: Date.today + 1.month, estimated_hours: 11, state: "open")


  huggey_bears.update_columns(user_id: 1)
  amnesty_international.update_columns(user_id: 2)
  global_giving.update_columns(user_id: 3)

  john_doe = Fabricate(:user, user_group: "nonprofit")
  user_signs_in(john_doe)
  expect(page).to have_content("You are logged in!")

  visit projects_path
  expect(page).to have_content("#{word_press.title}")
  expect(page).to have_content("#{rails_app.title}")
  expect(page).to have_content("#{nice_pages.title}")
  expect(page).to have_content("#{pretty_logo.title}")
  expect(page).to have_content("#{fundraising.title}")
  expect(page).to have_content("#{facebook_help.title}")
  expect(page).to have_content("#{tax_assistance.title}")
  expect(page).to have_content("#{social_media.title}")
  

  find("input[value='Web Development']").set(true)
  click_on("Search")

  expect(page).to have_content("#{word_press.title}")
  expect(page).to have_content("#{rails_app.title}")
  expect(page).to have_content("#{nice_pages.title}")
  expect(page).to_not have_content("#{fundraising.title}")
  expect(page).to_not have_content("#{pretty_logo.title}")
  expect(page).to_not have_content("#{fundraising.title}")
  expect(page).to_not have_content("#{facebook_help.title}")
  expect(page).to_not have_content("#{tax_assistance.title}")
  expect(page).to_not have_content("#{social_media.title}")
    
  end
  scenario "user logs in and searches for a project with a keyword search" do
    huggey_bears = Organization.create(name: "Huggey Bear Land", cause: "Animal Rights", ruling_year: 1998, 
    mission_statement: "We want to give everyone a huggey bear in their sad times", guidestar_membership: nil, 
    ein: "192512653-6", street1: "2998 Hansen Heights", street2: nil, city: "New York", 
    state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
    budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
    goal: "We want 1 out of every 5 Americans to have a huggey bear.")

  amnesty_international = Organization.create(name: "Amnesty International", cause: "Human Rights", ruling_year: 1912,
    mission_statement: "We want to see human rights spread across the globe -- chyea.", guidestar_membership: nil, 
    ein: "987931299-1", street1: "3293 Dunnit Hill", street2: nil, city: "New York", 
    state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
    budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
    goal: "Every year we want at least one thousand human rights activists released from prisons around the world.")

  global_giving = Organization.create(name: "Global Giving", cause: "Social Good", ruling_year: 2000, 
    mission_statement: "We make it rain on Nonprofits, erreday", guidestar_membership: nil, 
    ein: "222222222-2", street1: "2222 Rick Ross", street2: nil, city: "DC", 
    state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
    budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
    goal: "We want each of our nonprofit partners to raise at least $ 5,000.00 from our platform a year.")

  word_press = Project.create(title: "Need WordPress Site", description: "I want a nice looking WordPress site for my nonprofit", 
    skills: "Web Development", causes: "animals", deadline: Date.today + 1.month, organization_id: huggey_bears.id, estimated_hours: 22, state: "open")
  pretty_logo = Project.create(title: "Elegant Logo", description: "I want a logo that reflects the strenght of the human spirit!", 
    skills: "Graphic Design", causes: "human rights", deadline: Date.today + 1.month, organization_id: amnesty_international.id, estimated_hours: 32, state: "open")
  social_media = Project.create(title: "Twitter Help", description: "I need someone to push out 10 tweets a day for me", 
    organization_id: global_giving.id, skills: "Social Media", causes: "social", deadline: Date.today + 1.month, estimated_hours: 11, state: "open")
  fundraising = Project.create(title: "Fundraising Help", description: "I need help fundraising my organization", 
    skills: "Fundraising", causes: "animals", deadline: Date.today + 1.month, organization_id: huggey_bears.id, estimated_hours: 22, state: "open")
  rails_app = Project.create(title: "Ruby on Rails Application", description: "I want robust, agile software to help ", 
    skills: "Web Development", causes: "animals", deadline: Date.today + 1.month, organization_id: amnesty_international.id, estimated_hours: 22, state: "open")
  nice_pages = Project.create(title: "Front-end Design", description: "I need someone to snaz up our current organization's pages", 
    organization_id: global_giving.id, skills: "Web Development", causes: "social", deadline: Date.today + 1.month, estimated_hours: 11, state: "open")
  facebook_help = Project.create(title: "Facebook assistance", description: "We need someone to help run a facebook campaign", 
    skills: "Fundraising", causes: "animals", deadline: Date.today + 1.month, organization_id: huggey_bears.id, estimated_hours: 22, state: "open")
  tax_assistance = Project.create(title: "Accounting Help", description: "We forgot to do our taxes. O well.....", 
    organization_id: global_giving.id, skills: "Accounting", causes: "social", deadline: Date.today + 1.month, estimated_hours: 11, state: "open")

  alice = User.create(organization_id: 1, first_name: "Alice", last_name: "Smith", email: "alice@huggey_bear.org", 
    interests: "Animal Rights", skills: "Grant Writing", street1: nil, street2: nil, 
    city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
    organization_staff: nil, volunteer: nil, position: "Executive Director", password: "password", user_group: "nonprofit")
  bob = User.create(organization_id: 2, first_name: "Bob", last_name: "Adams", email: "bob@amnesty.org", 
    interests: "Human Rights", skills: "Web Development", street1: nil, street2: nil, 
    city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
    organization_staff: nil, volunteer: nil, position: "Executive Director", password: "password", user_group: "nonprofit")
  catherine = User.create(organization_id: 3, first_name: "Catherine", last_name: "Hemingway", email: "cat@globalgiving.org", 
    interests: "Health", skills: "Graphic Design", street1: nil, street2: nil, 
    city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
    organization_staff: nil, volunteer: nil, position: "Executive Director", password: "password", user_group: "nonprofit")

  huggey_bears.update_columns(user_id: 1)
  amnesty_international.update_columns(user_id: 2)
  global_giving.update_columns(user_id: 3)

  john_doe = Fabricate(:user, user_group: "nonprofit")
  user_signs_in(john_doe)
  expect(page).to have_content("You are logged in!")

  visit projects_path
  expect(page).to have_content("#{word_press.title}")
  expect(page).to have_content("#{rails_app.title}")
  expect(page).to have_content("#{nice_pages.title}")
  expect(page).to have_content("#{pretty_logo.title}")
  expect(page).to have_content("#{fundraising.title}")
  expect(page).to have_content("#{facebook_help.title}")
  expect(page).to have_content("#{tax_assistance.title}")
  expect(page).to have_content("#{social_media.title}")
  
  fill_in "Search", with: "front"
  click_on("Search")

  expect(page).to have_content("#{nice_pages.title}")
  expect(page).to_not have_content("#{rails_app.title}")
  expect(page).to_not have_content("#{pretty_logo.title}")
  expect(page).to_not have_content("#{fundraising.title}")
  expect(page).to_not have_content("#{facebook_help.title}")
  expect(page).to_not have_content("#{tax_assistance.title}")
  expect(page).to_not have_content("#{social_media.title}")

  end
end
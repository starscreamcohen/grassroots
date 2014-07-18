require 'spec_helper'

feature  "Volunteer applies to a project"do
  scenario "Volunteer applies to a project and administrator sees the application" do
    huggey_bear = Fabricate(:organization, name: "Huggey Bear Land", cause: "Animal Rights", ruling_year: 1998, 
      mission_statement: "We want to give everyone a huggey bear in their sad times", guidestar_membership: nil, 
      ein: "192512653-6", street1: "2998 Hansen Heights", street2: nil, city: "New York", 
      state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
      budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
      goal: "We want 1 out of every 5 Americans to have a huggey bear.")

    alice = Fabricate(:user, organization_id: 1, first_name: "Alice", last_name: "Smith", email: "alice@huggey_bear.org", 
      interests: "Animal Rights", street1: nil, street2: nil, 
      city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
      organization_staff: nil, volunteer: nil, position: "Executive Director", password: "password", user_group: "nonprofit")
    huggey_bear.update_columns(user_id: 1)
    bob = Fabricate(:user, first_name: "Bob", last_name: "Seltzer", email: "jacob@example.org", 
      interests: "Web Development", street1: nil, street2: nil, 
      city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: nil, 
      organization_staff: nil, volunteer: true, password: "password", user_group: "volunteer")
    word_press = Fabricate(:project, title: "Need WordPress Site", description: "I want a nice looking WordPress site for my nonprofit", 
      causes: "animals", deadline: Date.today + 1.month, 
      user_id: 1, organization_id: 1, estimated_hours: 22, state: "open")
    
    user_signs_in(bob)
    expect(page).to have_content("You are logged in!")

    visit projects_path
    
    expect(page).to have_content("Need WordPress Site")
    click_on('Join Project')
    fill_in "message[body]", with: "I'd like to join this project"
    
    click_on('Create')
    sign_out   

    user_signs_in(alice)
    visit conversations_path
    

    expect(page).to have_text("Volunteer Application")
  end
end
require 'spec_helper'

feature "Either volunteer or project administrator ends contract" do
 let(:huggey_bear) {Fabricate(:organization, name: "Huggey Bear Land", cause: "Animal Rights", ruling_year: 1998, 
   mission_statement: "We want to give everyone a huggey bear in their sad times", guidestar_membership: nil, 
   ein: "192512653-6", street1: "2998 Hansen Heights", street2: nil, city: "New York", 
   state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
   budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
   goal: "We want 1 out of every 5 Americans to have a huggey bear.")}

let(:alice) {Fabricate(:user, organization_id: 1, first_name: "Alice", last_name: "Smith", email: "alice@huggey_bear.org", 
  interests: "Animal Rights", street1: nil, street2: nil, 
  city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
  organization_staff: nil, volunteer: nil, position: "Executive Director", password: "password", user_group: "nonprofit")}

let(:bob) {Fabricate(:user, first_name: "Bob", last_name: "Seltzer", email: "jacob@example.org", 
  interests: "Web Development", street1: nil, street2: nil, 
  city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: nil, 
  organization_staff: nil, volunteer: true, password: "password", user_group: "volunteer")}
  
let(:word_press) {Fabricate(:project, title: "Need WordPress Site", description: "I want a nice looking WordPress site for my nonprofit", 
  skills: "web development", causes: "animals", deadline: Date.today + 1.month, 
  user_id: 1, organization_id: 1, estimated_hours: 22, state: "open")}

  scenario "volunteer completes the project", :js => true do
    alice
    bob
    huggey_bear.update_columns(user_id: 1)
    word_press

    volunteer_applies_to_project(bob)

    administrator_contracts_volunteer(alice)

    user_signs_in(bob)
    volunteer_submits_work_for_job_completion(bob)
    sign_out

    user_signs_in(alice)
    project_administrator_confirms_contracts_completion(alice)
    sign_out

    user_signs_in(bob)
    expect(page).to have_text("Completed Work 1")
  end

  scenario "volunteer drops the project" do
    alice
    bob
    huggey_bear.update_columns(user_id: 1)
    word_press

    volunteer_applies_to_project(bob)

    administrator_contracts_volunteer(alice)

    user_signs_in(bob)
    volunteer_drops_project(bob)
    sign_out

    user_signs_in(alice)
    visit conversations_path
    expect(page).to have_content("Bob Seltzer has been dropped on this project. This is an automated message.")
    sign_out
  end

  scenario "project administrator drops volunteer" do
    alice
    bob
    huggey_bear.update_columns(user_id: 1)
    word_press

    volunteer_applies_to_project(bob)

    administrator_contracts_volunteer(alice)

    user_signs_in(alice)
    project_administrator_drops_project(alice)
    sign_out

    user_signs_in(bob)
    volunteer_sees_contract_has_been_dropped
    sign_out
  end

  def project_administrator_drops_project(admin)
    visit organization_path(admin.organization.id)
    expect(page).to have_content("Projects in Production 1")
    visit conversations_path
    click_on("Drop Volunteer")
    #page.find(:xpath, "//a[@href='/dropping_contract?conversation_id=#{Conversation.first.id}']").click
    visit organization_path(admin.organization.id)
    expect(page).to have_content("Available Projects 1")
    expect(page).to have_content("Projects in Production 0")
    expect(page).to have_content("Completion Request 0")
    expect(page).to have_content("Completed Projects 0")
    expect(page).to have_content("Unfinished 0")
  end

  def volunteer_sees_contract_has_been_dropped
    expect(page).to have_content("Open Applications 0")
    expect(page).to have_content("Work in Production 0")
    expect(page).to have_content("Submitted Work 0")
    expect(page).to have_content("Completed Work 0")
    visit conversations_path
    expect(page).to have_content("Bob Seltzer has been dropped on this project. This is an automated message.")
  end

  def volunteer_drops_project(volunteer)
    expect(page).to have_content("Work in Production 1")
    visit conversations_path
    click_on("Drop Project")
    #page.find(:xpath, "//a[@href='/dropping_contract?conversation_id=#{Conversation.first.id}']").click
    #click_on("Drop Contract")
    #click_on("Drop Project")
    visit user_path(volunteer.id)
    expect(page).to have_content("Open Applications 0")
    expect(page).to have_content("Work in Production 0")
    expect(page).to have_content("Submitted Work 0")
    expect(page).to have_content("Completed Work 0")
  end

  def volunteer_submits_work_for_job_completion(volunteer)
    find(:xpath, "//a[@href='/users/#{volunteer.id}?tab=in+production']").click()
    
    wait_for_ajax
    click_on("Project Complete")
    
    
    fill_in "message[body]", with: "This is done"
    click_on('Create')
    visit user_path(volunteer.id)
    expect(page).to have_text("Submitted Work 1")
  end

  def project_administrator_confirms_contracts_completion(administrator)
    visit organization_path(administrator.organization.id)
    expect(page).to have_content("Completion Request 1")
    visit conversations_path
    expect(page).to have_text("Contract Complete")
    click_on('Contract Complete')
    click_on('Completed')
    fill_in "message[body]", with: "Great work."
    click_on('Send')
    visit organization_path(administrator.organization.id)
    expect(page).to have_text("Completed Projects 1")
  end

  def volunteer_applies_to_project(user)
    user_signs_in(user)
    expect(page).to have_content("You are logged in!")
    visit projects_path
    expect(page).to have_content("Need WordPress Site")
    click_on('Join Project')
    fill_in "message[body]", with: "I'd like to join this project"
    
    click_on('Create')
    sign_out   
    
  end

  def administrator_contracts_volunteer(user)
    user_signs_in(user)
    visit conversations_path
    click_on("Volunteer Application")
    click_on("Accept")
    #page.find(:xpath, "//a[@href='/contracts?conversation_id=#{Conversation.first.id}&volunteer_application_id=#{VolunteerApplication.first.id}']").click
    
    fill_in "message[body]", with: "I have accepted your participation"
    click_on('Send')
    visit conversations_path
    expect(page).to have_text("Drop Contract")
    visit organization_path(user.organization.id)
    expect(page).to have_text("Projects in Production 1")
    sign_out
  end
end
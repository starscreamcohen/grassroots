require 'spec_helper'

feature 'Users newsfeed becomes populated with activity' do
  let!(:bob) {Fabricate(:user, first_name: "Bob", last_name: "Adams", 
    email: "bob@example.come", user_group: "volunteer")}
  let!(:profile_completion) {Fabricate(:badge, name: "100% User Profile Completion")}

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

  let!(:alice_question) {Fabricate(:question, user_id: alice.id, title: "How do I set up WordPress", description: "Should I get a host first?")}
  let!(:bob_question) {Fabricate(:question, user_id: bob.id, title: "How do I talk to my Web Developer?", description: "I'm new to web development, 
      but I'd like to learn how to talk to a developer. Any advice would be great.") }

  let!(:uncategorized) {Fabricate(:category, name: "Uncategorized")}
  let!(:web_development) {Fabricate(:category, name: "Web Development")}
  let!(:graphic_design) {Fabricate(:category, name: "Graphic Design")}
  let!(:social_media) {Fabricate(:category, name: "Social Media")}

  scenario 'The user sees the earned profile completion badge on his/her newsfeed' do
    user_signs_in(bob)
    visit edit_user_path(bob)
    fills_out_profile
    
    visit newsfeed_items_path
    expect(page).to have_content("100% User Profile Completion")
  end

  scenario 'The user sees the project he/she just created on the newsfeed' do
    huggey_bears.update_columns(user_id: 1)
    user_signs_in(alice)
    visit new_organization_admin_project_path

    fills_out_project_form
    expect(page).to have_text("You successfully created a project")
    visit newsfeed_items_path
    expect(page).to have_content("WordPress Help")
  end

  scenario 'The user sees his/her question created in the forums on the newsfeed' do
    user_signs_in(bob)
    visit questions_path
    click_on('Ask a question')

    fill_in "Title", with: "PHP Advice"
    fill_in "Description", with: "I want to learn PHP. Where do I start?"
    find("input[value='2']").set(true)
    click_on('Post question')
    expect(page).to have_content("PHP Advice")

    visit newsfeed_items_path
    expect(page).to have_content("PHP Advice")
  end

  scenario 'The user sees his/her answer on the forums on the newsfeed' do
    user_signs_in(bob)
    visit questions_path

    answers_question

    visit newsfeed_items_path
    expect(page).to have_content("You should do this....")
  end

  scenario 'The user contributes an update to the newsfeed' do
    user_signs_in(bob)
    visit newsfeed_items_path

    fill_in "status_update[content]", with: "I had a great day volunteering."
    expect(page).to have_content("I had a great day volunteering")
  end

  def fills_out_profile
    find('#user_state_abbreviation').find(:xpath, 'option[35]').select_option
    fill_in "user[city]", with: "New York"
    fill_in "user[position]", with: "Freelancer"
    fill_in "user[interests]", with: "Environment"
    fill_in "user[contact_reason]", with: "If you need help with a website"  
    fill_in "user[bio]", with: "I'm from Brooklyn. chyea."
    click_on("Update")
  end

  def fills_out_project_form
    find("#project_deadline_2i").find(:xpath,"./option[contains(.,'October')]").selected?
    find("#project_deadline_3i").find(:xpath,"./option[contains(.,'15')]").selected?
    find("#project_deadline_1i").find(:xpath,"./option[contains(.,'2014')]").selected?
    fill_in "project[estimated_hours]", with: "25"
    fill_in "project[title]", with: "WordPress Help"
    fill_in "project[description]", with: "I need a word press website."
    find(:xpath, "//input[@id='project_organization_id']").set "1"
    click_button 'Create'
  end

  def answers_question
    click_on("#{alice_question.title}")
    fill_in "answer[description]", with: "You should do this...."
    click_on("Post Your Answer")
    expect(page).to have_content("You should do this....")
  end
end 
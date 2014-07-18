require 'spec_helper'

feature 'User has a conversation with messages with other user' do 
  scenario "A user messages another user and that user replies to the message" do
    alice = Fabricate(:user, user_group: "nonprofit")
    bob = Fabricate(:user, user_group: "volunteer")

    amnesty = Fabricate(:organization, name: "Amnesty International", cause: "Human Rights", ruling_year: 1912,
      mission_statement: "We want to see human rights spread across the globe -- chyea.", guidestar_membership: nil, 
      ein: "987931299-1", street1: "3293 Dunnit Hill", street2: nil, city: "New York", 
      state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
      budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
      goal: "Every year we want at least one thousand human rights activists released from prisons around the world.", user_id: alice.id)

    alice.update_columns(organization_id: amnesty.id)

    user_signs_in(bob)
    visit organizations_path

    page.check("Human Rights")
    click_on("Search")
    page.find(:xpath, "//a[@href='/organizations/#{amnesty.id}']").click
    click_on("Overview")
    click_on("Message")
    
    fill_in "message[subject]", with: "question about projects"
    fill_in "message[body]", with: "Why do you not have any projects open?"
    click_on('Create')
    sign_out

    user_signs_in(alice)
    visit conversations_path
    
    click_on("question about projects")
    fill_in "message[body]", with: "I'm going to post one in a few days. What is your background?"
    click_on('Send')
    sign_out

    user_signs_in(bob)
    visit conversations_path
    click_on("question about projects")
    expect(page).to have_content("I'm going to post one in a few days. What is your background?")
    fill_in "message[body]", with: "I build web applications and would be interested in helping out."
    click_on("Send")
    sign_out

    user_signs_in(alice)
    visit conversations_path
    expect(page).to have_content("I build web applications and would be interested in helping out.")
  end
end

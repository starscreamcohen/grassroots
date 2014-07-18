require 'spec_helper'

feature 'User engages with the newsfeed' do 
  let!(:alice) {Fabricate(:user, user_group: "volunteer")}
  let!(:bob) {Fabricate(:organization_administrator, user_group: "nonprofit")}
  let!(:huggey_bears) {Fabricate(:organization, name: "Huggey Bear Land", cause: "Animal Rights", ruling_year: 1998, 
    mission_statement: "We want to give everyone a huggey bear in their sad times", guidestar_membership: nil, 
    ein: "192512653-6", street1: "2998 Hansen Heights", street2: nil, city: "New York", 
    state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
    budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
    goal: "We want 1 out of every 5 Americans to have a huggey bear.")}
  
  scenario 'user comments on one of the newsfeed items of his users network' do
    huggey_bears.update_columns(user_id: 2)
    alice.follow!(bob)
    user_signs_in(bob)
    visit new_organization_admin_project_path
    fills_out_project_form
    sign_out

    newsfeed_item2 = NewsfeedItem.find(2)
    user_signs_in(alice)
    visit newsfeed_items_path
    
    fill_in "#{newsfeed_item2.newsfeedable_type}", with: "that looks like a cool project"
    click_on("Comment on the project")
    expect(page).to have_text("that looks like a cool project")
    
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
end
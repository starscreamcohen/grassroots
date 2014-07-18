require 'spec_helper'

feature 'User earns badges through his/her activity' do 
  scenario 'user received a profile completion badge' do
    john_signs_in
    john = User.first
    visit edit_user_path(john)
    profile_completion = Badge.create(name: "100% User Profile Completion")

    find('#user_state_abbreviation').find(:xpath, 'option[35]').select_option
    fill_in "user[city]", with: "New York"
    fill_in "user[position]", with: "Freelancer"
    fill_in "user[interests]", with: "Environment"
    fill_in "user[contact_reason]", with: "If you need help with a website"  
    fill_in "user[bio]", with: "I'm from Brooklyn. chyea."
    click_on("Update")
    expect(page).to have_content("100% User Profile Completion")
  end

  def john_signs_in
    visit new_user_path
    fill_in "Email", with: "john@example.com"
    fill_in "Password", with: "password"
    fill_in "First Name", with: "John"
    fill_in "Last Name", with: "Smith"
    choose('user_user_group_volunteer', visible: false)
    click_on("Create")
  end
end
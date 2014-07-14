require 'spec_helper'

feature "User creates an organization" do
  scenario "user registers as a nonprofit and while filling out his/her profile he is routed to create an orgnaization" do
    john_signs_in
    john = User.first

    expect(page).to have_text("John Smith")
    expect(page).to have_text("37%")
    expect(john.reload.organization_administrator).to eq(nil)

    click_on("Update Your Profile and Find Your Organization")

    updates_profile_and_becomes_org_administrator
    expect(page).to have_text("Create Your Organization")

    expect(john.reload.organization_administrator).to eq(true)

    creates_organization
    expect(page).to have_text("You created your organization.")
  end

  def john_signs_in
    visit new_user_path
    fill_in "Email", with: "john@example.com"
    fill_in "Password", with: "password"
    fill_in "First Name", with: "John"
    fill_in "Last Name", with: "Smith"
    choose('user_user_group_nonprofit', visible: false)
    click_on("Create")
  end

  def updates_profile_and_becomes_org_administrator
    fill_in "Position", with: "john@example.com"
    fill_in "Interests", with: "John"
    fill_in "Last name", with: "Smith"  
    fill_in "Contact me for", with: "Opportunities at Huggey Bear Land"  
    fill_in "Bio", with: "I'm from Brooklyn. chyea."
    fill_in "Organization name box", with: "Huggey Bear Land"
    click_on("Update")
  end

  def creates_organization
    fill_in "Name", with: "Huggey Bear Land"
    fill_in "EIN", with: "123456-78"
    fill_in "Cause", with: "Health"
    fill_in "Mission statement", with: "We are doing are best to keep Bostonians from smoking crack. It's really hard."  
    fill_in "Goal", with: "We want at least one Bostonian a month to stop smoking crack."
    fill_in "organization[street1]", with: "55 Brighton"  
    fill_in "City", with: "Boston"
    select("MA", :from => "organization[state_abbreviation]")
    fill_in "Zip", with: "12345"
    fill_in "Contact number", with: "555-555-5555"
    fill_in "Contact email", with: "john@example.com"
    click_on("Create")
  end
end

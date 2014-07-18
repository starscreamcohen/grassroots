require 'spec_helper'

feature 'User engages the forum and other users on it' do 
  let!(:alice) {Fabricate(:user, organization_id: 1, first_name: "Alice", last_name: "Smith", email: "alice@huggey_bear.org", 
  interests: "Animal Rights", street1: nil, street2: nil, 
  city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
  organization_staff: nil, volunteer: nil, position: "Executive Director", password: "password", user_group: "nonprofit")}

  let!(:bob) {Fabricate(:user, first_name: "Bob", last_name: "Seltzer", email: "jacob@example.org", 
  interests: "Web Development", street1: nil, street2: nil, 
  city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: nil, 
  organization_staff: nil, volunteer: true, password: "password", user_group: "volunteer")}

  let!(:alice_question) {Fabricate(:question, user_id: alice.id, title: "How do I set up WordPress", description: "Should I get a host first?")}
  let!(:bob_question) {Fabricate(:question, user_id: bob.id, title: "How do I talk to my Web Developer?", description: "I'm new to web development, 
      but I'd like to learn how to talk to a developer. Any advice would be great.") }

  let!(:uncategorized) {Fabricate(:category, name: "Uncategorized")}
  let!(:web_development) {Fabricate(:category, name: "Web Development")}
  let!(:graphic_design) {Fabricate(:category, name: "Graphic Design")}
  let!(:social_media) {Fabricate(:category, name: "Social Media")}

  scenario 'user signs in to ask a question on the forums' do
    alice_question.categories << web_development
    bob_question.categories << web_development
    
    john_doe = Fabricate(:user, user_group: "nonprofit")
    user_signs_in(john_doe)
    
    visit questions_path
    expect(page).to have_content("#{alice_question.title}")
    expect(page).to have_content("#{bob_question.title}")
    click_on('Ask a question')

    fill_in "Title", with: "PHP Advice"
    fill_in "Description", with: "I want to learn PHP. Where do I start?"
    find("input[value='2']").set(true)
    click_on('Post question')
    expect(page).to have_content("PHP Advice")
  end

  scenario 'user signs in to comment on a question' do
    alice_question.categories << web_development
    bob_question.categories << web_development
    
    john_doe = Fabricate(:user, user_group: "nonprofit")
    user_signs_in(john_doe)
    
    visit questions_path
    expect(page).to have_content("#{alice_question.title}")
    expect(page).to have_content("#{bob_question.title}")
    click_on("#{alice_question.title}")
    fill_in "comment[content]", with: "that's a great question"
    click_on("Comment on the question")
    expect(page).to have_content("that's a great question")
  end

  scenario 'user signs in to answer a question' do
    alice_question.categories << web_development
    bob_question.categories << web_development
    
    john_doe = Fabricate(:user, user_group: "nonprofit")
    user_signs_in(john_doe)
    
    visit questions_path
    expect(page).to have_content("#{alice_question.title}")
    expect(page).to have_content("#{bob_question.title}")
    click_on("#{alice_question.title}")
    fill_in "answer[description]", with: "You should do this...."
    click_on("Post Your Answer")
    expect(page).to have_content("You should do this....")
  end

  scenario 'user signs in to comment on an answer' do
    alice_question.categories << web_development
    bob_question.categories << web_development
    alice_answer = Fabricate(:answer, user_id: alice.id, description: "you should do this and that", question_id: bob_question.id)
    
    john_doe = Fabricate(:user, user_group: "nonprofit")
    user_signs_in(john_doe)
    
    visit questions_path
    expect(page).to have_content("#{alice_question.title}")
    expect(page).to have_content("#{bob_question.title}")
    click_on("#{bob_question.title}")
    expect(page).to have_content("you should do this and that")
    
    fill_in "comment_answer", with: "that's a great answer"
    click_on("Comment on the answer")
    expect(page).to have_content("that's a great answer")
  end
end
Organization.destroy_all
huggey_bears = Organization.create(name: "Huggey Bear Land", cause: "Animal Rights", ruling_year: 1998, 
  mission_statement: "We want to give everyone a huggey bear in their sad times", guidestar_membership: nil, 
  ein: "192512653-6", street1: "2998 Hansen Heights", street2: nil, city: "New York", small_cover: "profile_photo.png",
  state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
  budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
  goal: "We want 1 out of every 5 Americans to have a huggey bear.")

amnesty_international = Organization.create(name: "Amnesty International", cause: "Human Rights", ruling_year: 1912,
  mission_statement: "We want to see human rights spread across the globe -- chyea.", guidestar_membership: nil, 
  ein: "987931299-1", street1: "3293 Dunnit Hill", street2: nil, city: "New York", small_cover: "profile_photo.png",
  state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
  budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
  goal: "Every year we want at least one thousand human rights activists released from prisons around the world.")
global_giving = Organization.create(name: "Global Giving", cause: "Social Good", ruling_year: 2000, 
  mission_statement: "We make it rain on Nonprofits, erreday", guidestar_membership: nil, 
  ein: "222222222-2", street1: "2222 Rick Ross", street2: nil, city: "DC", small_cover: "profile_photo.png",
  state_id: 0, zip: "28200-1366", ntee_major_category_id: 0, funding_method: nil, user_id: nil,
  budget: "$22,000,000.00", contact_number: "555-555-5555", contact_email: "test@example.com",
  goal: "We want each of our nonprofit partners to raise at least $ 5,000.00 from our platform a year.")

User.destroy_all

alice = User.create(organization_id: 1, first_name: "Alice", last_name: "Smith", email: "alice@huggey_bear.org", 
  street1: nil, street2: nil, small_cover: "profile_photo.png",
  city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
  organization_staff: nil, volunteer: nil, position: "Executive Director", password: "password", user_group: "nonprofit")
bob = User.create(organization_id: 2, first_name: "Bob", last_name: "Adams", email: "bob@amnesty.org", 
  street1: nil, street2: nil, small_cover: "profile_photo.png",
  city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
  organization_staff: nil, volunteer: nil, position: "Executive Director", password: "password", user_group: "nonprofit")
catherine = User.create(organization_id: 3, first_name: "Catherine", last_name: "Hemingway", email: "cat@globalgiving.org", 
  street1: nil, street2: nil,  small_cover: "profile_photo.png",
  city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: true, 
  organization_staff: nil, volunteer: nil, position: "Executive Director", password: "password", user_group: "nonprofit")
dan = User.create(organization_id: 1, first_name: "Daniel", last_name: "Montgomey", email: "dan@huggey_bear.org", 
  street1: nil, street2: nil,  small_cover: "profile_photo.png",
  city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: nil, 
  organization_staff: true, volunteer: nil, position: "Business Development Executive", password: "password", user_group: "nonprofit")
elena = User.create(organization_id: 1, first_name: "Elena", last_name: "Lincoln", email: "elena@huggey_bear.org", 
  street1: nil, street2: nil,  small_cover: "profile_photo.png",
  city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: nil, 
  organization_staff: true, volunteer: nil, position: "Fundraising Manager", password: "password", user_group: "nonprofit")
fred = User.create(organization_id: 2, first_name: "Fred", last_name: "Montgomery", email: "fred@amnesty.org", 
  street1: nil, street2: nil,  small_cover: "profile_photo.png",
  city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: nil, 
  organization_staff: true, volunteer: nil, position: "Junior Associate", password: "password", user_group: "nonprofit")
genna = User.create(organization_id: 2, first_name: "Genna", last_name: "Kennedy", email: "genna@amnesty.org", 
  street1: nil, street2: nil,  small_cover: "profile_photo.png",
  city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: nil, 
  organization_staff: true, volunteer: nil, position: "Event Coordinator", password: "password", user_group: "nonprofit")
harry = User.create(organization_id: 3, first_name: "Harry", last_name: "Swift", email: "harry@global.org", 
  street1: nil, street2: nil, small_cover: "profile_photo.png",
  city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: nil, 
  organization_staff: true, volunteer: nil, position: "Financial Officer", password: "password", user_group: "nonprofit")
ingrid = User.create(organization_id: 3, first_name: "Ingrid", last_name: "Washington", email: "ingrid@global.org", 
  street1: nil, street2: nil, small_cover: "profile_photo.png",
  city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: nil, 
  organization_staff: true, volunteer: nil, position: "IT", password: "password", user_group: "nonprofit")
jacob = User.create(first_name: "Jacob", last_name: "Seltzer", email: "jacob@example.org", 
  street1: nil, street2: nil, small_cover: "profile_photo.png",
  city: "New York", state_id: "NY", phone_number: nil, zip: nil, organization_administrator: nil, 
  organization_staff: nil, volunteer: true, password: "password", user_group: "volunteer")

kate_daniels = User.create(first_name: "Kate", last_name: "Daniels", 
  email: "kate@example.org",
  street1: nil, street2: nil, city: "Birmingham", password: "password", state_id: "AL", phone_number: nil, 
  zip: nil, organization_administrator: nil, organization_staff: nil, volunteer: true, 
  user_group: "volunteer")
larry_nunez = User.create(first_name: "Larry", last_name: "Nunez", 
  email: "larry@example.org", password: "password", 
  street1: nil, street2: nil, city: "Boston", state_id: "MA", phone_number: nil, 
  zip: nil, organization_administrator: nil, organization_staff: nil, volunteer: true, 
  user_group: "volunteer")
maria_jacobs = User.create(first_name: "Maria", last_name: "Jacobs", password: "password", 
  email: "maria@example.org",
  street1: nil, street2: nil, city: "Boston", state_id: "MA", phone_number: nil, 
  zip: nil, organization_administrator: nil, organization_staff: nil, volunteer: true, 
  user_group: "volunteer")
nancy_smith = User.create(first_name: "Nancy", last_name: "Smith", 
  email: "nancy@example.org",
  street1: nil, street2: nil, city: "New York", password: "password", state_id: "NY", phone_number: nil, 
  zip: nil, organization_administrator: nil, organization_staff: nil, volunteer: true, 
  user_group: "volunteer")


huggey_bears.update_columns(user_id: 1)
amnesty_international.update_columns(user_id: 2)
global_giving.update_columns(user_id: 3)


Project.destroy_all
word_press = Project.create(title: "Need WordPress Site", description: "I want a nice looking WordPress site for my nonprofit", 
  causes: "animals", deadline: Date.today + 1.month, organization_id: huggey_bears.id, estimated_hours: 22, state: "open")
pretty_logo = Project.create(title: "Elegant Logo", description: "I want a logo that reflects the strenght of the human spirit!", 
  causes: "human rights", deadline: Date.today + 1.month, organization_id: amnesty_international.id, estimated_hours: 32, state: "open")
socialmedia = Project.create(title: "Twitter Help", description: "I need someone to push out 10 tweets a day for me", 
  organization_id: global_giving.id, causes: "social", deadline: Date.today + 1.month, estimated_hours: 11, state: "open")
fundraising = Project.create(title: "Fundraising Help", description: "I need help fundraising my organization", 
  causes: "animals", deadline: Date.today + 1.month, organization_id: huggey_bears.id, estimated_hours: 22, state: "open")
rails_app = Project.create(title: "Ruby on Rails Application", description: "I want robust, agile software to help ", 
  causes: "animals", deadline: Date.today + 1.month, organization_id: amnesty_international.id, estimated_hours: 22, state: "open")
nice_pages = Project.create(title: "Front-end Design", description: "I need someone to snaz up our current organization's pages", 
  organization_id: global_giving.id, causes: "social", deadline: Date.today + 1.month, estimated_hours: 11, state: "open")
facebook_help = Project.create(title: "Facebook assistance", description: "We need someone to help run a facebook campaign", 
  causes: "animals", deadline: Date.today + 1.month, organization_id: huggey_bears.id, estimated_hours: 22, state: "open")
tax_assistance = Project.create(title: "Accounting Help", description: "We forgot to do our taxes. O well.....", 
  organization_id: global_giving.id,causes: "social", deadline: Date.today + 1.month, estimated_hours: 11, state: "open")

Category.destroy_all
uncategorized = Category.create(name: "Uncategorized")
web_development = Category.create(name: "Web Development")
graphic_design = Category.create(name: "Graphic Design")
social_media = Category.create(name: "Social Media")

Question.destroy_all
alice_question = Question.create(user_id: alice.id, title: "How do I set up WordPress", description: "Should I get a host first?")
bob_question = Question.create(user_id: bob.id, title: "How do I talk to my Web Developer?", description: "I'm new to web development, but I'd like 
  to learn how to talk to a developer. Any advice would be great.")
cat_question = Question.create(user_id: catherine.id, title: "What's the best way to solicit a Graphic Designer?", description: "How 
  should I go about doing this?")
dan_question = Question.create(user_id: dan.id, title: "Twitter question", description: "How many tweets should I do a day?")
alice_question2 = Question.create(user_id: alice.id, title: "GR Question", description: "How do I speak with GR support?")

alice_question.categories << web_development
bob_question.categories << web_development
cat_question.categories << graphic_design
dan_question.categories << social_media
alice_question2.categories << uncategorized

Badge.destroy_all
profile_completion = Badge.create(name: "100% User Profile Completion")

Skill.destroy_all
Skill.create(name: "Grant Writing")
Skill.create(name: "Web Development")
Skill.create(name: "Graphic Design") 
Skill.create(name: "Business Planning")
Skill.create(name: "Accounting")

Relationship.destroy_all
relationship = Relationship.create(follower: alice, leader: bob)
relationship = Relationship.create(follower: alice, leader: catherine)

NewsfeedItem.destroy_all
newsfeed_item1 = NewsfeedItem.create(user_id: bob.id, created_at: Date.today)
pretty_logo.newsfeed_items << newsfeed_item1

newsfeed_item2 = NewsfeedItem.create(user_id: catherine.id, created_at: 2.days.ago)
socialmedia.newsfeed_items << newsfeed_item2

newsfeed_item3 = NewsfeedItem.create(user_id: bob.id, created_at: 3.days.ago)
rails_app.newsfeed_items << newsfeed_item3

newsfeed_item4 = NewsfeedItem.create(user_id: catherine.id, created_at: 4.days.ago)
nice_pages.newsfeed_items << newsfeed_item4

newsfeed_item5 = NewsfeedItem.create(user_id: bob.id, created_at: 5.days.ago)
tax_assistance.newsfeed_items << newsfeed_item5

Contract.destroy_all  
Message.destroy_all
Conversation.destroy_all
Vote.destroy_all
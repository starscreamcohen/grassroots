Fabricator(:user) do
  email { Faker::Internet.email }
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name }
  password { 'password' }
  #interests { ["Environment", "Human Rights", "Urban Issues", "Transportation", "Health"].sample }
  position {["Executive Director", "Product Manager", "Office Manager", "Intern", "Outreach Manager"].sample}
  organization_administrator false
end  

Fabricator(:organization_administrator, from: :user) do
  organization_administrator true
end
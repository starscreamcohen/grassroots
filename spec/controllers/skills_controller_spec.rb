require 'spec_helper'

describe SkillsController, :type => :controller do
  describe 'POST create' do
    let!(:alice) {Fabricate(:user, first_name: "Alice", user_group: "volunteer")}
    let!(:graphic_design) {Fabricate(:skill, name: "Graphic Design")}

    before(:each) do
      set_current_user(alice)
      request.env["HTTP_REFERER"] = "/users/1/edit" unless request.nil? or request.env.nil?
    end
    
    it "redirects back to the edit profile page" do
      post :create, skill: {name: ""}
      expect(response).to redirect_to(edit_user_path(alice))
    end
    
    it "associates a skill with the user" do
      post :create, skill: {name: "Graphic Design"}
      expect(alice.skills).to match_array([graphic_design])
    end

    it "creates a new skill if skill does not exist" do
      post :create, skill: {name: "Ruby on Rails"}
      expect(Skill.count).to eq(2)
    end
  end
end
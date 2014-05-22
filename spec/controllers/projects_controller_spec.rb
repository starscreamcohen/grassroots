require 'spec_helper'

describe ProjectsController do
  describe "GET index" do
    it "shows all of the projects on Grassroots" do
      word_press = Fabricate(:project, title: "WordPress Site")
      logo = Fabricate(:project, title: "Huggey Bear Logo")
      brochures = Fabricate(:project, title: "Schmancy Brochures")
      web_development = Fabricate(:project, title: "Maintain Drupal Site")

      get :index
      expect(assigns(:projects)).to match_array([word_press, logo, brochures, web_development])
    end
  end

  describe "GET show" do
    it "shows a project" do
      word_press = Fabricate(:project, title: "WordPress Site")

      get :show, id: word_press
      expect(assigns(:project)).to eq(word_press)
    end
    context "when there are other requests to join"
     it "shows all freenlancers thumbnails"
  end

  describe "GET search" do
    it "redirects to the results page" do
      get :search
      expect(response).to render_template(:search)
    end
    it "shows only the projects within a certain skill set" do
      word_press = Fabricate(:project, title: "WordPress Site", skills: "web development")
      get :search, skills: word_press.skills

      expect(assigns(:results)).to eq([word_press])
    end
    it "shows the projects under a certain cause" do
      huggey_bear = Fabricate(:organization, cause: "animals")
      word_press = Fabricate(:project, title: "WordPress Site", skills: "web development", causes: "animals", organization_id: huggey_bear.id)
      get :search, causes: "animals"

      expect(assigns(:results)).to eq([word_press])
    end

    it "shows the projects with one or more submitted skill sets" do
      word_press = Fabricate(:project, title: "WordPress Site", skills: "web development")
      logo = Fabricate(:project, title: "Logo Redesign", skills: "graphic design")
      get :search, skills: [word_press.skills, logo.skills]
      
      expect(assigns(:results)).to eq([word_press, logo])
    end
  end


  describe "GET accept" do
    it "changes the projects state from pending to in production"
    it "makes the project move from the pending tab to the in production tab on the freelancer’s and the organization admin’s dashboard"
    it "notifies the user waiting for a response that someone accepted the user’s join request"
  end

  describe "GET complete" do
    it "changes the projects state from in production to completed"
    it "notifies the other user that this project is completed"
    it "sends a feedback form to all parties involved"
    it "moves the project from the tab, in production, to the tab, completed"
  end
=begin
  describe "POST join"
    ##I do not know if this should change the project's state 
    ##when a PM is made to join or if PrivateMessage#create_join_request should    
  end
  describe "GET accept" do
    it "changes the projects state from pending to in production"
    it "makes the project move from the pending tab to the in production tab on the freelancer’s and the organization admin’s dashboard"
    it "notifies the user waiting for a response that someone accepted the user’s join request"
  end

  describe "GET complete" do
    it "changes the projects state from in production to completed"
    it "notifies the other user that this project is completed"
    it "sends a feedback form to all parties involved"
    it "moves the project from the tab, in production, to the tab, completed"
  end
=end
end
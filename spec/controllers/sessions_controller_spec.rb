require 'spec_helper'

describe SessionsController, :type => :controller do
  let(:alice) { Fabricate(:user, user_group: "nonprofit")}
  describe 'GET new' do
    it "renders the new template for unauthenticated users" do
      get :new
      expect(response).to render_template(:new)
    end
    it "redirects to the current user's profile page for authenticated users" do
      session[:user_id] = alice.id
      get :new

      expect(response).to redirect_to(user_path(alice))
    end
  end

  describe 'POST create' do
    context 'with valid input' do
      it "sets the user in the session if user is authenticated" do
        post :create, email: alice.email, password: alice.password

        expect(session[:user_id]).to eq(alice.id)
      end
      it "sends the user to his profile page when the user is authenticated" do
        post :create, email: alice.email, password: alice.password

        expect(response).to redirect_to(user_path(alice))
      end
      it "sets the notice" do
        post :create, email: alice.email, password: alice.password

        expect(flash[:notice]).to eq("You are logged in!")
      end
    end

    context 'with invalid input' do
      it "does not put the signed in user in the session" do
        post :create, email: "wrong@email.com", password: alice.password

        expect(session[:user_id]).to be_nil
      end

      it "redirects the user to the new tempate when the password and email are invalid" do
        post :create, email: "wrong@email.com", password: alice.password

        expect(response).to render_template(:new)
      end

      it "sets the error message" do
        post :create, email: "wrong@email.com", password: alice.password

        expect(flash[:notice]).to eq("Either the password or the email is invalid.")
      end
    end
  end
  describe 'GET destroy' do
    it "clears the sessions for the user" do
      post :create, email: alice.email, password: alice.password

      get :destroy
      expect(session[:user_id]).to be_nil
    end
    
    it "redirects to the root path" do
      post :create, email: alice.email, password: alice.password

      get :destroy
      expect(response).to redirect_to(root_path)
    end
    
    it "sets the notice" do
      post :create, email: alice.email, password: alice.password

      get :destroy
      expect(flash[:notice]).to eq("You are logged out.")
    end

  end
end
require 'spec_helper'

describe Users::OmniauthCallbacksController do

  describe "GET 'twitter'" do
    describe "create success" do 
      before(:each) do 
        @user = FactoryGirl.create(:user, :twitter_id => '123') 
        User.stub(:find_or_create_for_twitter_oauth).and_return(@user)
      end 

      it "returns http success" do
        get 'twitter'
        response.should redirect_to(apps_path)
      end
    end 

    describe "create fail" do 
      before(:each) do 
        @user = FactoryGirl.build(:user) 
        User.stub(:find_or_create_for_twitter_oauth).and_return(@user)
      end 

      it "redirects" do 
        get 'twitter'
        response.should redirect_to(new_user_session_path)
      end
    end 
  end

  describe "GET 'github'" do
    describe "create success" do 
      before(:each) do 
        @user = FactoryGirl.create(:user, :twitter_id => '456') 
        User.stub(:find_or_create_for_github_oauth).and_return(@user)
      end 
  
      it "returns http success" do
        get 'github'
        response.should redirect_to(apps_path)
      end
    end 

    describe "create fail" do 
      before(:each) do 
        @user = FactoryGirl.build(:user) 
        User.stub(:find_or_create_for_github_oauth).and_return(@user)
      end 

      it "returns http success" do
        get 'github'
        response.should redirect_to(new_user_session_path)
      end
    end 
  end

end

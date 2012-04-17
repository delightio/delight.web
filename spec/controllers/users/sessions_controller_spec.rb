require 'spec_helper'

describe Users::SessionsController do

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "DELETE 'destroy'" do
    describe "user signed in" do 
      before(:each) do 
        @user = FactoryGirl.create(:user) 
        sign_in(@user) 
      end 

      it "returns http success" do
        delete 'destroy'
        response.should redirect_to(root_path)
      end
    end 

    it "returns http success" do
      delete 'destroy'
      response.should redirect_to(root_path)
    end
  end

end

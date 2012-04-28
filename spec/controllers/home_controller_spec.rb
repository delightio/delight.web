require 'spec_helper'

describe HomeController do

  describe "GET 'index'" do
    let(:user) { FactoryGirl.create(:user) }
    describe "user signed in" do
      before(:each) do
        sign_in(user)
      end
      it "should redirect user to apps page" do
        get 'index'
        response.should redirect_to(apps_path)
      end
    end
    describe "user not sigend in" do
      it "returns http success" do
        get 'index'
        response.should be_success
      end
    end
  end

end

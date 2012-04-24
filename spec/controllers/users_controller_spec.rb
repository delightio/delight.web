require 'spec_helper'

describe UsersController do

  let(:user) { FactoryGirl.create(:user) }

  describe "GET 'edit'" do
    describe "signed in" do
      before(:each) do
        sign_in(user)
      end

      it "returns http success" do
        get 'edit'
        response.should be_success
      end
    end

    describe "not signed in" do
      it "returns http success" do
        get 'edit'
        response.should redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET 'update'" do
    describe "signed in" do
      before(:each) do
        user.signup_step = 1
        user.save!
        user.signup_step.should == 1
        sign_in(user)
      end

      it "returns http success" do
        get 'update', { :user => { :nickname => 'newnick', :email => '123@example.com', :signup_step => 2 } }
        response.should redirect_to(apps_path)
        assigns(:user).should be_valid
        assigns(:user).nickname.should == 'newnick'
        assigns(:user).email.should == '123@example.com'
        assigns(:user).signup_step.should == 2
      end
    end

    describe "not signed in" do
      before(:each) do
        user.signup_step = 1
        user.save!
      end

      it "returns http success" do
        get 'update', { :user => { :nickname => 'newnick', :email => '123@example.com', :signup_step => 2 } }
        response.should redirect_to(new_user_session_path)
        user.reload
        user.signup_step.should == 1
      end
    end
  end

end

require 'spec_helper'

describe ApplicationController do
  controller do
    def index
      render :nothing => true
    end

    def after_sign_in_path_for(resource)
      super resource
    end

    def check_user_registration
      super
    end
  end

  let(:user) { FactoryGirl.create(:user, :signup_step => 1) }
  let(:viewer) { FactoryGirl.create(:viewer, :signup_step => 1) }
  let(:admin) { FactoryGirl.create(:administrator, :signup_step => 1) }

  describe "check user registration" do
    describe "not signed in" do
      it "should redirect user to sign in page" do
        get 'index'
        response.should be_success # no additional redirect
      end
    end

    describe "signed in as admin" do
      before(:each) do
        sign_in(admin)
      end
      it "should redirect to apps page if there is account and app and signup complete" do
        admin.signup_step = 2
        admin.save!
        account = admin.create_account(:name => "test account")
        account.apps.create(:name => "test app")
        get 'index'
        response.should be_success # no additional redirect
      end
      it "should redirect user to force account create page if no account" do
        admin.signup_step = 2
        admin.save!
        get 'index'
        response.should redirect_to user_signup_info_edit_path(admin)
      end
      it "should redirect user to force account create page if no app" do
        admin.signup_step = 2
        admin.save!
        account = admin.create_account(:name => "test account")
        get 'index'
        response.should redirect_to user_signup_info_edit_path(admin)
      end
      it "should redirect user to force account create page if no app" do
        get 'index'
        response.should redirect_to user_signup_info_edit_path(admin)
      end
      it "should redirect user to force account create page if signup not completed" do
        get 'index'
        response.should redirect_to user_signup_info_edit_path(admin)
      end
    end

    describe "signed in as viewer" do
      before(:each) do
        sign_in(viewer)
      end
      it "should redirect user to edit user page" do
        get 'index'
        response.should redirect_to edit_user_path(viewer)
      end
    end

    describe "signed in as user" do
      before(:each) do
        sign_in(user)
      end
      it "should redirect user to edit user page" do
        get 'index'
        response.should redirect_to edit_user_path(user)
      end
    end
  end

end

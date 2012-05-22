require 'spec_helper'

describe InvitationsController do

  let(:invitation) { FactoryGirl.create(:invitation) }
  let(:viewer) { FactoryGirl.create(:viewer) }
  let(:app) { FactoryGirl.create(:app) }

  describe "GET 'new'" do
    describe "user not signed in" do
      it "should redirect to sign in page" do
        get "new", { :app_id => app.id }
        response.should redirect_to(new_user_session_path)
      end
    end

    describe "signed in as non admin" do
      before(:each) do
        sign_in(viewer)
      end
      it "should redirect to apps path "do
        get "new", { :app_id => app.id }
        response.should redirect_to(apps_path)
      end
    end

    describe "signed in as non owner admin" do
      let(:app2) { FactoryGirl.create(:app) }
      let(:admin2) { app2.account.administrator }
      before(:each) do
        sign_in(admin2)
      end

      it "should redirect to apps path" do
        get "new", { :app_id => app.id }
        response.should redirect_to(apps_path)
      end
    end

    describe "signed in as owner admin" do
      before(:each) do
        sign_in(app.account.administrator)
      end
      it "should success" do
        get "new", { :app_id => app.id }
        response.should be_success
      end
    end
  end

  describe "POST 'create'" do
    describe "user not signed in" do
      it "should redirect to sign in page" do
        post 'create',
            :group_invitation => {
              :app_id => app.id,
              :emails => "test@example.com",
              :app_session_id => nil,
              :message => nil
            }, :format => :json
        response.response_code.should == 401
      end
    end

    describe "signed in as non admin" do
      before(:each) do
        sign_in(viewer)
      end
      it "should fail" do
        post 'create',
            :group_invitation => {
              :app_id => app.id,
              :emails => "test@example.com",
              :app_session_id => nil,
              :message => nil
            }, :format => :json
        response.should be_success
        result = JSON.parse(response.body)
        result["result"].should == "fail"
        result["reason"].should == "user is not administrator"
      end
    end

    describe "signed in as non owner admin" do
      let(:app2) { FactoryGirl.create(:app) }
      let(:admin2) { app2.account.administrator }
      before(:each) do
        sign_in(admin2)
      end
      it "should fail" do
        post 'create',
            :group_invitation => {
              :app_id => app.id,
              :emails => "test@example.com",
              :app_session_id => nil,
              :message => nil
            }, :format => :json
        response.should be_success
        result = JSON.parse(response.body)
        result["result"].should == "fail"
        result["reason"].should == "invalid app id"
      end
    end

    describe "signed in as admin app owner" do
      before(:each) do
        sign_in(app.account.administrator)
      end
      it "should create new invitation" do
        post 'create',
            :group_invitation => {
              :app_id => app.id,
              :emails => "test@example.com",
              :app_session_id => nil,
              :message => nil
            }, :format => :json
        response.should be_success
        result = JSON.parse(response.body)
        result["result"].should == "success"
        assigns(:group_invitation).should be_valid
        assigns(:group_invitation).app_id.should == app.id
        assigns(:group_invitation).emails.should == "test@example.com"
      end

      it "should accept invitation for particular session" do
        new_session = AppSession.create
        app.app_sessions << new_session
        post 'create',
            :group_invitation => {
              :app_id => app.id,
              :emails => "test@example.com",
              :app_session_id => new_session.id,
              :message => nil
            }, :format => :json
        response.should be_success
        result = JSON.parse(response.body)
        result["result"].should == "success"
        assigns(:group_invitation).should be_valid
        assigns(:group_invitation).app_id.should == app.id
        assigns(:group_invitation).emails.should == "test@example.com"
        assigns(:group_invitation).app_session_id.should == new_session.id
      end

      it "should fail without email" do
        post 'create',
             :group_invitation => {
                :app_id => app.id,
                :app_session_id => nil,
                :message => nil
             }, :format => :json
        response.should be_success
        result = JSON.parse(response.body)
        result["result"].should == "fail"
        result["reason"].should == "Cannot create new invitation"
      end

      it "should fail without app id" do
        post 'create',
            :group_invitation => {
              :emails => "test@example.com",
              :app_session_id => nil,
              :message => nil,
            }, :format => :json
        response.should be_success
        result = JSON.parse(response.body)
        result["result"].should == "fail"
        result["reason"].should == "invalid app id"
      end
    end
  end

  describe "GET 'show'" do
    describe "user not signed in" do
      it "should require signin and add session vars" do
        get 'show', { :id => invitation.id, :token => invitation.token }
        response.should redirect_to(new_user_session_path)
        session['omniauth.viewer'].should be_true
        session['omniauth.redirect'].should == invitation_path(:id => invitation.id, :token => invitation.token)
      end
    end

    describe "viewer signed in" do
      before(:each) do
        sign_in(viewer)
      end

      it "should success" do
        get 'show', { :id => invitation.id, :token => invitation.token }
        response.should be_success
        assigns(:invitation).should == invitation
      end

      it "should show error when token is missing" do
        get 'show', { :id => invitation.id }
        response.should redirect_to(apps_path)
        flash[:notice].should == 'Token missing'
      end

      it "should show error when invitation not found" do
        get 'show', { :id => invitation.id, :token => '123' }
        response.should redirect_to(apps_path)
        flash[:notice].should == 'Invalid request'
      end

      it "should show error when token has expired" do
        invitation.token_expiration = 1.day.ago
        invitation.save!
        get 'show', { :id => invitation.id, :token => invitation.token }
        response.should redirect_to(apps_path)
        flash[:notice].should == 'Token expired'
      end
    end
  end

  describe "PUT accept" do
    describe "user not signed in" do
      it "should require signin and add session vars" do
        put 'accept', { :id => invitation.id, :token => invitation.token }
        response.should redirect_to(new_user_session_path)
        session['omniauth.viewer'].should be_true
        session['omniauth.redirect'].should == invitation_path(:id => invitation.id, :token => invitation.token)
      end
    end

    describe "user signed in" do

      before(:each) do
        sign_in(viewer)
      end

      it "should success" do
        put 'accept', { :invitation_id => invitation.id, :token => invitation.token }
        response.should redirect_to(app_path(invitation.app.to_param))
        assigns(:invitation).should == invitation
        flash[:notice].should == 'Successfully accepted invitation'
        invitation.reload
        invitation.token_expiration.should <= Time.now
        invitation.app.viewers.should include(viewer)
      end

      it "should success whne invitation has app_session_id" do
        invitation.app_session_id = 100
        invitation.save!
        put 'accept', { :invitation_id => invitation.id, :token => invitation.token }
        response.should redirect_to(app_path(invitation.app.to_param, :app_session_id => 100))
        assigns(:invitation).should == invitation
        flash[:notice].should == 'Successfully accepted invitation'
        invitation.reload
        invitation.token_expiration.should <= Time.now
        invitation.app.viewers.should include(viewer)
      end

      it "should fail when token is missing" do
        put 'accept', { :invitation_id => invitation.id }
        response.should redirect_to(apps_path)
        flash[:notice].should == 'Token missing'
      end

      it "should fail when invitation not found" do
        put 'accept', { :invitation_id => invitation.id, :token => '123' }
        response.should redirect_to(apps_path)
        flash[:notice].should == 'Invalid request'
      end

      it "should show error when token has expired" do
        invitation.token_expiration = 1.day.ago
        invitation.save!
        put 'accept', { :invitation_id => invitation.id, :token => invitation.token }
        response.should redirect_to(apps_path)
        flash[:notice].should == 'Token expired'
      end

    end
  end
end

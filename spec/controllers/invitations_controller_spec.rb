require 'spec_helper'

describe InvitationsController do

  let(:invitation) { FactoryGirl.create(:invitation) }
  let(:viewer) { FactoryGirl.create(:viewer) }

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

require 'spec_helper'

describe TracksController do
  let(:app_session) { FactoryGirl.create :app_session}
  describe "post" do
    it "creates new track object" do
      params = { app_session_id: app_session.id }
      post :create, format: :xml, track: params
      response.should be_success
      #response.response_code.should == 201
    end

    pending "it should return correct xml"
    pending "it should return response code 201"

    it "returns 400 if missing parameters" do
      post :create, track: {}
      response.should_not be_success
    end
  end

  describe "show" do
    let(:viewer) { FactoryGirl.create(:viewer) }
    let(:track) { FactoryGirl.create(:track) }
    before(:each) do
      track.app_session.favorite_users << viewer
    end

    describe "user signed in" do
      before(:each) do
        sign_in(viewer)
      end
      describe "user has permission" do
        before(:each) do
          viewer.apps << track.app_session.app
        end

        it "should show track" do
          get 'show', { :id => track.id }
          response.should be_success
          assigns(:track).should == track
        end
      end

      describe "user has no permission" do
        it "should redirect to apps path" do
          get 'show', { :id => track.id }
          response.should redirect_to(apps_path)
        end
      end
    end

    describe "user not signed in" do
      it "should redirect to sign in page" do
        get 'show', { :id => track.id }
        response.should redirect_to(new_user_session_path)
      end
    end
  end
end

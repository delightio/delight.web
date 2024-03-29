require 'spec_helper'

describe TracksController do
  let(:app_session) { FactoryGirl.create :app_session}
  describe "post" do
    it "creates new track object" do
      request.env['HTTP_X_NB_AUTHTOKEN'] = app_session.app.token
      params = { app_session_id: app_session.id }
      post :create, format: :xml, track: params
      response.should be_success
      #response.response_code.should == 201
    end

    pending "it should return correct xml"
    pending "it should return response code 201"

    it "returns 400 if missing parameters" do
      request.env['HTTP_X_NB_AUTHTOKEN'] = app_session.app.token
      post :create, track: {}
      response.should_not be_success
    end

    it "should fail if token is missing" do
      params = { app_session_id: app_session.id }
      post :create, format: :xml, track: params
      response.should be_bad_request
    end

    it "should fail if token is incorrect" do
      request.env['HTTP_X_NB_AUTHTOKEN'] = 'wrongtoken'
      params = { app_session_id: app_session.id }
      post :create, format: :xml, track: params
      response.should be_bad_request
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

    context "when the request is json" do
      before(:each) do
        request.accept = 'application/json'
        track.app_session = app_session
        track.save
      end

      xit "renders presigned read uri" do
        request.env['HTTP_X_NB_AUTHTOKEN'] = app_session.app.token
        get 'show', { id: track.id }
        response.should be_success
      end

      xit "rejects if missing token" do
        get 'show', { id: track.id }
        puts response
        response.should be_bad_request
      end

      xit "rejects mismatched token" do
        request.env['HTTP_X_NB_AUTHTOKEN'] = "badtoken"
        get 'show', { id: track.id }
        puts response
        response.should be_bad_request
      end
    end
  end

  describe "authenicate_by_token!" do
    it 'rejects missing token'
    it 'rejects mismatched token'
  end
end

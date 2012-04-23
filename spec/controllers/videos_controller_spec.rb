require 'spec_helper'

describe VideosController do
  let(:uri) { "abc" }
  let(:app_session) { FactoryGirl.create :app_session}
  describe "post" do
    it "creates new video object" do
      params = { uri: uri, app_session_id: app_session.id }
      post :create, format: :xml, video: params
      response.should be_success
    end

    it "returns 400 if missing parameters" do
      post :create, video: {}
      response.should_not be_success
    end
  end

  describe "show" do
    let(:viewer) { FactoryGirl.create(:viewer) }
    let(:video) { FactoryGirl.create(:video) }
    before(:each) do
      video.app_session.favorite_users << viewer
    end

    describe "user signed in" do
      before(:each) do
        sign_in(viewer)
      end
      describe "user has permission" do
        before(:each) do
          viewer.apps << video.app_session.app
        end

        it "should show video" do
          get 'show', { :id => video.id }
          response.should be_success
          assigns(:video).should == video
        end
      end

      describe "user has no permission" do
        it "should redirect to apps path" do
          get 'show', { :id => video.id }
          response.should redirect_to(apps_path)
        end
      end
    end

    describe "user not signed in" do
      it "should redirect to sign in page" do
        get 'show', { :id => video.id }
        response.should redirect_to(new_user_session_path)
      end
    end
  end
end

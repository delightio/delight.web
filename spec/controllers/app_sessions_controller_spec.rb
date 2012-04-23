require 'spec_helper'

describe AppSessionsController do
  describe 'post' do
    let(:app) { FactoryGirl.create :app }
    let(:app_version) { '1.4' }
    let(:app_build) { 'KJKJ'}
    let(:delight_version) { '0.1' }
    let(:locale) { 'en-US' }

    it 'creates' do
      params = { app_token: app.token,
                 app_version: app_version,
                 app_build: app_build,
                 locale: locale,
                 delight_version: delight_version }
      post :create, app_session: params, format: :xml
      response.should be_success
    end

    context 'when missing parameters' do
      let(:bad_params) { {} }
      it 'returns 400'
      it 'returns non 2xx code' do
        post :create, app_session: bad_params, format: :xml
        response.should_not be_success
      end
    end
  end

  describe 'put' do
    let(:app_session) { FactoryGirl.create :app_session }

    let(:duration) { 10.2 }
    it 'updates duration' do
      params = { duration: duration }
      put :update, id: app_session.id, app_session: params, format: :xml
      response.should be_success
      app_session.reload.duration.should == duration
    end

    let(:app_user_id) { '10' }
    it 'updates app_user_id' do
      params = { app_user_id: app_user_id }
      put :update, id: app_session.id, app_session: params, format: :xml
      response.should be_success
      app_session.reload.app_user_id.should == app_user_id
    end
  end

  describe 'GET show' do
    let(:app_session) { FactoryGirl.create :app_session }
    let(:viewer) { FactoryGirl.create :viewer }
    let(:user) { FactoryGirl.create :user }

    describe 'signed in' do
      describe 'as admin' do
        before(:each) do
          sign_in(app_session.app.account.administrator)
        end

        it "should return ok" do
          get 'show', { :id => app_session.id }
          response.should be_ok
          assigns(:app_session).should == app_session
        end
      end

      describe 'as viewer' do
        before(:each) do
          app_session.app.viewers << viewer
          sign_in(viewer)
        end

        it "should return ok" do
          get 'show', { :id => app_session.id }
          response.should be_ok
          assigns(:app_session).should == app_session
        end
      end

      describe 'user not authorized' do
        before(:each) do
          sign_in(user)
        end

        it "should redirect to apps listing" do
          get 'show', { :id => app_session.id }
          response.should redirect_to(apps_path)
        end
      end

      describe 'viewer not authorized' do
        before(:each) do
          sign_in(viewer)
        end

        it "should redirect to apps listing" do
          get 'show', { :id => app_session.id }
          response.should redirect_to(apps_path)
        end
      end

      describe 'admin not authorized' do
        let(:admin2) { FactoryGirl.create(:administrator) }
        before(:each) do
          sign_in(admin2)
        end

        it "should redirect to apps listing" do
          get 'show', { :id => app_session.id }
          response.should redirect_to(apps_path)
        end
      end
    end

    describe 'not signed in' do
      it "should redirect to sign in page" do
        get 'show', { :id => app_session.id }
      end
    end

  end

  describe 'PUT favorite' do
    let(:app_session) { FactoryGirl.create :app_session }
    let(:viewer) { FactoryGirl.create(:viewer) }
    before(:each) do
      sign_in(viewer)
    end

    describe 'user has permission' do
      before(:each) do
        viewer.apps << app_session.app
      end
      it "should add to favorite" do
        put 'favorite', { :app_session_id => app_session.id, :format => :json }
        response.should be_success
        result = JSON.parse(response.body)
        result['result'].should == 'success'
        app_session.reload
        app_session.favorite_users.should == [viewer]
      end
    end

    describe 'user has no permission' do
      it "should fail" do
        put 'favorite', { :app_session_id => app_session.id, :format => :json }
        response.should be_success
        result = JSON.parse(response.body)
        result['result'].should == 'fail'
        result['reason'].should == 'record not found'
      end
    end
  end

  describe 'PUT unfavorite' do
    let(:app_session) { FactoryGirl.create :app_session }
    let(:viewer) { FactoryGirl.create(:viewer) }
    before(:each) do
      app_session.favorite_users << viewer
      sign_in(viewer)
    end

    describe 'user has permission' do
      before(:each) do
        viewer.apps << app_session.app
      end
      it "should remove from favorite" do
        put 'unfavorite', { :app_session_id => app_session.id, :format => :json }
        response.should be_success
        result = JSON.parse(response.body)
        result['result'].should == 'success'
        app_session.reload
        app_session.favorite_users.should == []
      end
    end

    describe 'user has no permission' do
      it "should fail" do
        put 'unfavorite', { :app_session_id => app_session.id, :format => :json }
        response.should be_success
        result = JSON.parse(response.body)
        result['result'].should == 'fail'
        result['reason'].should == 'record not found'
      end
    end
  end

end

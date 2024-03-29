require 'spec_helper'

describe AppSessionsController do
  describe 'post' do
    render_views
    let(:app) { FactoryGirl.create :non_recording_app }
    let(:delight_version) { '2' }
    let(:app_version) { '1.4' }
    let(:app_build) { 'KJKJ'}
    let(:app_locale) { 'en-US' }
    let(:app_connectivity) { 'wifi' }
    let(:device_hw_version) { 'iPhone 4.1' }
    let(:device_os_version) { '4.1' }

    before(:each) do
      @params = {app_version: app_version,
                 app_build: app_build,
                 app_locale: app_locale,
                 app_connectivity: app_connectivity,
                 device_hw_version: device_hw_version,
                 device_os_version: device_os_version,
                 delight_version: delight_version }
    end

    it 'creates' do
      request.env['HTTP_X_NB_AUTHTOKEN'] = app.token
      post :create, app_session: @params, format: :xml
      response.should be_success
      #response.response_code.should == 201

      xml = response.body
      xml.should have_xpath('//app_session')
      xml.should have_xpath('//app_session/id')
      xml.should have_xpath('//app_session/recording')
    end

    # https://github.com/delightio/delight.ios/issues/5
    it 'handles extra properties sent in with POST /app_sessions' do
      extra_params = @params.clone
      extra_params[:properties] = { blah: mock }
      extra_params[:metrics] = { blah: mock }

      request.env['HTTP_X_NB_AUTHTOKEN'] = app.token
      post :create, app_session: extra_params, format: :xml
      response.should be_success
    end

    it "should fail when app token is missing" do
      post :create, app_session: @params, format: :xml
      response.should be_bad_request
    end

    it "should fail if token is wrong" do
      request.env['HTTP_X_NB_AUTHTOKEN'] = 'wrongtoken'
      post :create, app_session: @params, format: :xml
      response.should be_bad_request
#    # LH 110
#    it 'creates with version 1 params' do
#      params = { app_token: app.token,
#                 app_version: app_version,
#                 app_build: app_build,
#                 # app_locale: app_locale,
#                 locale: app_locale,
#                 # app_connectivity: app_connectivity,
#                 # device_hw_version: device_hw_version,
#                 # device_os_version: device_os_version,
#                 delight_version: '1.0.1' }
#      post :create, app_session: params, format: :xml
#      response.should be_success
    end

    pending "it should return code 201"

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
    before { request.env['HTTP_X_NB_AUTHTOKEN'] = app_session.app.token }
    let(:app_session) { FactoryGirl.create :app_session }

    let(:duration) { 10.2 }
    it 'updates duration' do
      params = { duration: duration }
      put :update, id: app_session.id, app_session: params, format: :xml
      response.should be_success
      app_session.reload.duration.should == duration
    end

    it "should fail if token is missing" do
      request.env.delete 'HTTP_X_NB_AUTHTOKEN'
      params = { duration: duration }
      put :update,  id: app_session.id, app_session: params, format: :xml
      response.should be_bad_request
    end

    it "should fail if token is wrong" do
      request.env['HTTP_X_NB_AUTHTOKEN'] = 'wrongtoken'
      params = { duration: duration }
      put :update, id: app_session.id, app_session: params, format: :xml
      response.should be_bad_request
    end

    it 'updates properties' do
      params = { properties: { level: 20 } }
      put :update, id: app_session.id, app_session: params, format: :xml
      response.should be_success
      app_session.reload.properties.first.key.should   == 'level'
      app_session.reload.properties.first.value.should == '20'
    end

    it 'updates metrics' do
      params = { metrics: { call_count: '10' } }
      put :update, id: app_session.id, app_session: params, format: :xml
      response.should be_success
      app_session.reload.metrics(:call_count).should == 10
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
        let(:app2) { FactoryGirl.create(:app) }
        let(:admin2) { app2.account.administrator }
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

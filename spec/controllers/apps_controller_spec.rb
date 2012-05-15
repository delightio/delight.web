require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe AppsController do

  # This should return the minimal set of attributes required to create a valid
  # App. As you add validations to App, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { :name => 'test app name' }
  end

  let(:app) { FactoryGirl.create(:app) }
  let(:user) { FactoryGirl.create(:user) }

  describe "GET index" do
    let(:app2) { FactoryGirl.create(:app) }
    let(:viewer) { FactoryGirl.create(:viewer) }
    before(:each) do
      app.viewers.push viewer
      app2.viewers.push app.account.administrator
    end

    describe "user not signed in" do
      it "should redirect to user sign in path" do
        get :index
        response.should redirect_to(new_user_session_path)
      end
    end

    describe "user signed in" do
      before(:each) do
        sign_in(user)
      end

      it "assigns @viewer_apps" do
        get :index, {}
        assigns(:viewer_apps).should be_blank
        assigns(:admin_apps).should be_blank
      end
    end

    describe "viewer signed in" do
      before(:each) do
        sign_in(viewer)
      end

      it "assigns @viewer_apps" do
        get :index, {}
        assigns(:viewer_apps).should == [app]
        assigns(:admin_apps).should be_blank
      end
    end

    describe "admin signed in" do
      before(:each) do
        sign_in(app.account.administrator)
      end

      it "assigns @viewer_apps and @admin_apps" do
        get :index, {}
        assigns(:viewer_apps).should == [app2]
        assigns(:admin_apps).should == [app]
      end
    end
  end

  describe "GET show" do

    describe "user not signed in" do
      it "should redirect to user sign in page" do
        get :show, {:id => app.to_param}
        response.should redirect_to(new_user_session_path)
      end
    end

    describe "user signed in" do
      before(:each) do
        sign_in(user)
      end

      it "should return nil app" do
        get :show, {:id => app.to_param}
        assigns(:app).should be_nil
      end
    end

    describe "viewer signed in" do
      let(:viewer) { FactoryGirl.create(:viewer) }
      before(:each) do
        app.viewers.push viewer
        sign_out(user)
        sign_in(viewer)
      end

      it "should return app as @app" do
        get :show, {:id => app.to_param}
        assigns(:app).should == app
      end

      it "should have correct favorite ids" do
        session1 = FactoryGirl.create(:recorded_app_session, :app => app)
        session2 = FactoryGirl.create(:recorded_app_session, :app => app)
        session3 = FactoryGirl.create(:recorded_app_session, :app => app)

        app.app_sessions.should have(3).items
        session1.favorite_users << viewer
        session2.favorite_users << viewer

        get :show, {:id => app.to_param}

        assigns(:recorded_sessions).should include session1
        assigns(:recorded_sessions).should include session2
        assigns(:recorded_sessions).should include session3

        assigns(:favorite_app_session_ids).should include session1.id
        assigns(:favorite_app_session_ids).should include session2.id
        assigns(:favorite_app_session_ids).should_not include session3.id
      end

      it "should have correct favorite count including those out of current page" do
        sessions = (1..20).collect do
          s = FactoryGirl.create(:recorded_app_session, :app => app)
          s.favorite_users << viewer
          s
        end
        app.app_sessions.should have(20).items

        get :show, {:id => app.to_param}

        assigns(:favorite_count).should == 20
      end
    end

    describe "admin signed in" do
      before(:each) do
        sign_out(user)
        sign_in(app.account.administrator)
      end

      it "should return app as @app" do
        get :show, {:id => app.to_param}
        assigns(:app).should == app
      end

      it "should show have duration and date range including records in DB" do
        date_min = 31.days.ago - 15.minutes
        date_max = 10.seconds.ago

        session1 = FactoryGirl.create(:recorded_app_session, :app => app, :duration => 1, :created_at => 1.day.ago)
        session2 = FactoryGirl.create(:recorded_app_session, :app => app, :duration => 100.5, :created_at => date_min)
        session3 = FactoryGirl.create(:recorded_app_session, :app => app, :duration => 4.5, :created_at => date_max)
        session4 = FactoryGirl.create(:non_recording_app_session, :app => app, :duration => 150, :created_at => 1.year.ago)

        get :show, {:id => app.to_param}
        assigns(:recorded_sessions).should include session1
        assigns(:recorded_sessions).should include session2
        assigns(:recorded_sessions).should include session3
        assigns(:recorded_sessions).should_not include session4

        assigns(:default_date_min).should == 32 # 32 days ago
        assigns(:default_date_max).should == 0
        assigns(:default_duration_min).should == 1
        assigns(:default_duration_max).should == 101

      end

      describe "has properties" do
        let(:date_min) { 31.days.ago - 15.minutes }
        let(:date_max) { 10.seconds.ago }
        let(:session1) { FactoryGirl.create(:recorded_app_session, :app => app, :duration => 1, :created_at => 1.day.ago) }
        let(:session2) { FactoryGirl.create(:recorded_app_session, :app => app, :duration => 100.5, :created_at => date_min) }
        let(:session3) { FactoryGirl.create(:recorded_app_session, :app => app, :duration => 4.5, :created_at => date_max) }
        let(:session4) { FactoryGirl.create(:non_recording_app_session, :app => app, :duration => 150, :created_at => 1.year.ago) }
        before(:each) do
          session1.update_properties(:app_user_id => 'app_user_1', :some_key => 'some_value')
          session2.update_properties(:app_user_id => 'app_user_1')
          session3.update_properties(:app_user_id => 'app_user_2')
          session4.update_properties(:app_user_id => 'app_user_3')
        end

        it "should filter by app user id if given" do
          get :show, { :id => app.to_param, :properties => 'app_user_id : app_user_1' }
          response.should be_success
          sessions = assigns(:recorded_sessions)
          sessions.should have(2).items
          sessions.should include(session1)
          sessions.should include(session2)
        end

        it "should filter by any key value given" do
          puts session1.properties.to_yaml
          get :show, { :id => app.to_param, :properties => ' some_key: some_value ' }
          response.should be_success
          sessions = assigns(:recorded_sessions)
          sessions.should have(1).items
          sessions.should include(session1)
        end

        it "should return empty id if no match" do
          get :show, { :id => app.to_param, :properties => 'app_user_id:notexists' }
          response.should be_success
          sessions = assigns(:recorded_sessions)
          sessions.should be_empty
        end

        it "should not filter by app user id if not given" do
          get :show, { :id => app.to_param }
          response.should be_success
          sessions = assigns(:recorded_sessions)
          sessions.should have(3).items
          sessions.should include(session1)
          sessions.should include(session2)
          sessions.should include(session3)
        end

        it "should not filter by app user id if spaces are given" do
          get :show, { :id => app.to_param, :properties => '   ' }
          response.should be_success
          sessions = assigns(:recorded_sessions)
          sessions.should have(3).items
          sessions.should include(session1)
          sessions.should include(session2)
          sessions.should include(session3)
        end
      end
    end

  end

  describe "GET new" do
    describe "admin signed in" do
      before(:each) do
        sign_in(app.account.administrator)
      end

      it "assigns a new app as @app" do
        get :new, {}
        response.should be_ok
        new_app = assigns(:app)
        new_app.should be_a_new(App)
        new_app.account.administrator.should == app.account.administrator
      end
    end

    describe "non admin signed in" do
      before(:each) do
        sign_in(user)
      end

      it "should redirect to index page" do
        get :new
        response.should redirect_to(apps_url)
      end
    end

    describe "not signed in" do
      it "should redirect to user sign in path" do
        get :new
        response.should redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET edit" do
    describe "admin signed in" do
      before(:each) do
        sign_in(app.account.administrator)
      end

      it "should return app as @app" do
        get :edit, { :id => app.to_param }
        response.should be_ok
        assigns(:app).should == app
      end
    end

    describe "non admin signed in" do
      before(:each) do
        sign_in(user)
      end

      it "should redirect to index" do
        get :edit, { :id => app.to_param }
        response.should redirect_to(apps_path)
      end
    end

    describe "not signed in" do
      it "should redirect to user sign in path" do
        get :edit, { :id => app.to_param }
        response.should redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST create" do
    describe "not signed in" do
      it "should redirect to user sign in path" do
        post :create, { :app => valid_attributes }
        response.should redirect_to(new_user_session_path)
      end
    end

    describe "non admin signed in" do
      before(:each) do
        sign_in(user)
      end

      it "should redirect to app listing" do
        post :create, { :app => valid_attributes }
        response.should redirect_to(apps_path)
      end
    end

    describe "admin signed in" do
      before(:each) do
        sign_in(app.account.administrator)
      end

      describe "with valid params" do
        it "creates a new App" do
          expect {
            post :create, {:app => valid_attributes}
          }.to change(App, :count).by(1)
        end

        it "assigns a newly created app as @app" do
          post :create, {:app => valid_attributes}
          assigns(:app).should be_a(App)
          assigns(:app).should be_persisted
          assigns(:app).account.should == app.account
        end

        it "redirects to app view with setup param" do
          post :create, {:app => valid_attributes}
          response.should redirect_to(app_path(assigns(:app).to_param, :setup => true))
        end

        it 'schedules some recordings' do
          post :create, {:app => valid_attributes}
          new_app = assigns(:app)
          new_app.scheduled_recordings.should == Account::FreeCredits
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved app as @app" do
          # Trigger the behavior that occurs when invalid params are submitted
          App.any_instance.stub(:save).and_return(false)
          post :create, {:app => {}}
          assigns(:app).should be_a_new(App)
        end

        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          App.any_instance.stub(:save).and_return(false)
          post :create, {:app => {}}
          response.should render_template("new")
        end
      end
    end
  end

  describe "PUT update" do
    describe "not signed in" do
      it "should redirect to user sign in page" do
        put :update, {:id => app.to_param, :app => valid_attributes}
        response.should redirect_to(new_user_session_path)
      end
    end

    describe "non admin signed in" do
      before(:each) do
        sign_in(user)
      end

      it "should redirect to index" do
        put :update, {:id => app.to_param, :app => valid_attributes}
        response.should redirect_to(apps_path)
      end
    end

    describe "admin signed in" do
      before(:each) do
        sign_in(app.account.administrator)
      end

      describe "with valid params" do
        it "updates the requested app" do
          # Assuming there are no other apps in the database, this
          # specifies that the App created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          App.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
          put :update, {:id => app.to_param, :app => {'these' => 'params'}}
        end

        it "assigns the requested app as @app" do
          put :update, {:id => app.to_param, :app => valid_attributes}
          assigns(:app).should eq(app)
          assigns(:app).name.should == valid_attributes[:name]
        end

        it "redirects to app listing" do
          put :update, {:id => app.to_param, :app => valid_attributes}
          response.should redirect_to(apps_path)
        end
      end

      describe "with invalid params" do
        it "assigns the app as @app" do
          # Trigger the behavior that occurs when invalid params are submitted
          App.any_instance.stub(:save).and_return(false)
          put :update, {:id => app.to_param, :app => {}}
          assigns(:app).should eq(app)
        end

        it "re-renders the 'edit' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          App.any_instance.stub(:save).and_return(false)
          put :update, {:id => app.to_param, :app => {}}
          response.should render_template("edit")
        end
      end
    end
  end

  describe "DELETE destroy" do
    describe "admin signed in" do
      before(:each) do
        sign_in(app.account.administrator)
      end

      it "destroys the requested app" do
        expect {
          delete :destroy, {:id => app.to_param}
        }.to change(App, :count).by(-1)
      end

      it "redirects to the apps list" do
        delete :destroy, {:id => app.to_param}
        response.should redirect_to(apps_url)
      end
    end

    describe "view signed in" do
      let(:viewer) { FactoryGirl.create(:viewer) }
      before(:each) do
        app.viewers << viewer
        sign_in(viewer)
      end

      it "does not destroys the requested app" do
        expect {
          delete :destroy, {:id => app.to_param}
        }.to change(App, :count).by(0)
      end

      it "redirects to the apps list" do
        delete :destroy, {:id => app.to_param}
        response.should redirect_to(apps_url)
      end

    end
  end

  describe "PUT update_recording" do
    describe "admin signed in" do
      describe "owns the app" do
        before(:each) do
          sign_in(app.account.administrator)
        end
        it "should pause recording" do
          put 'update_recording', { :app_id => app.id, :state => 'pause', :format => :json }
          response.should be_success
          result = JSON.parse(response.body)
          result['result'].should == 'success'
          app.recording_paused?.should be_true
        end
        it "should resume recording" do
          put 'update_recording', { :app_id => app.id, :state => 'resume', :format => :json }
          response.should be_success
          result = JSON.parse(response.body)
          result['result'].should == 'success'
          app.recording_paused?.should be_false
        end
        it "should fail given invalid state" do
          put 'update_recording', { :app_id => app.id, :state => 'invalid', :format => :json }
          response.should be_success
          result = JSON.parse(response.body)
          result['result'].should == 'fail'
          result['reason'].should == 'invalid state'
          app.recording_paused?.should be_false
        end
      end

      describe "does not own app" do
        let(:app2) { FactoryGirl.create(:app) }
        let(:admin2) { app2.account.administrator }

        before(:each) do
          sign_in(admin2)
        end
        it "should fail" do
          put 'update_recording', { :app_id => app.id, :state => 'pause', :format => :json }
          response.should be_success
          result = JSON.parse(response.body)
          result['result'].should == 'fail'
          result['reason'].should == 'record not found'
          app.recording_paused?.should be_false
        end
      end
    end
    describe "other user signed in" do
      before(:each) do
        sign_in(user)
      end
      it "should fail" do
        put 'update_recording', { :app_id => app.id, :state => 'pause', :format => :json }
        response.should be_success
        result = JSON.parse(response.body)
        result['result'].should == 'fail'
        result['reason'].should == 'record not found'
        app.recording_paused?.should be_false
      end
    end
  end

  describe "GET setup" do
    before(:each) do
      sign_in(app.account.administrator)
    end

    it "should return success" do
      get 'setup', { :app_id => app.id }
      response.should be_success
      assigns(:app).should == app
    end
  end

  describe "GET schedule_recording_edit" do
    describe "admin signed in" do
      before(:each) do
        sign_in(app.account.administrator)
      end

      it "should increment the scheduled recording" do
        get 'schedule_recording_edit', { :app_id => app }
        response.should be_success
      end
    end

    describe "other account signed in" do
      before(:each) do
        sign_in(user)
      end
      it "should redirect to apps lisnt" do
        get 'schedule_recording_edit', { :app_id => app }
        response.should redirect_to(apps_path)
      end
    end
  end

  describe "PUT schedule_recording_update" do
    describe "admin signed in" do
      before(:each) do
        sign_in(app.account.administrator)
      end

      it "should set the scheduled recording with given amount" do
        put 'schedule_recording_update', { :app_id => app, :schedule_recording => 3 }
        response.should redirect_to(app_schedule_recording_edit_path(:app_id => app))
        flash[:notice].should == 'Successfully scheduled recordings'
        app.reload
        app.scheduled_recordings.should == 3
      end

      it "should render edit page with invalid param" do
        orig = app.scheduled_recordings
        put 'schedule_recording_update', { :app_id => app }
        response.should be_success
        app.reload
        app.scheduled_recordings.should == orig # no change
      end

      it "should not allow negative scheduled recording" do
        orig = app.scheduled_recordings
        put 'schedule_recording_update', { :app_id => app, :schedule_recording => -1  }
        response.should be_success
        app.reload
        app.scheduled_recordings.should == orig # no change
        flash.now[:notice].should == "Failed scheduling recordings"
      end
    end
  end

end

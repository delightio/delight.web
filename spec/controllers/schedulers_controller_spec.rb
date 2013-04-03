require 'spec_helper'

describe SchedulersController do
  before { sign_in(FactoryGirl.create :user) }
  let(:scheduler) { (FactoryGirl.create :app).scheduler }

  describe 'PUT update' do
    it 'updates recording state' do
      scheduler.stop_recording

      params = { recording: true }
      put :update, id: scheduler.id, scheduler: params, format: :json
      response.should be_success
      scheduler.reload.should be_recording
    end

    it 'updates wifi only option' do
      scheduler.set_wifi_only false

      params = { wifi_only: true}
      put :update, id: scheduler.id, scheduler: params, format: :json
      response.should be_success
      scheduler.reload.should be_wifi_only
    end
  end

  describe 'GET show' do
    it 'contains recording state and wifi option' do
      get :show, id: scheduler.id
      response.should be_success
      json = JSON.parse response.body
      json.should have_key("recording")
      json.should have_key("wifi_only")
    end
  end
end

require 'spec_helper'

describe PartnerAppSessionsController do
  describe 'post' do
    render_views
    let(:app) { FactoryGirl.create :recording_app }
    let(:delight_version) { '2' }
    let(:app_version) { '1.4' }
    let(:app_build) { 'KJKJ'}
    let(:app_locale) { 'en-US' }
    let(:app_connectivity) { 'wifi' }
    let(:device_hw_version) { 'iPhone 4.1' }
    let(:device_os_version) { '4.1' }
    let(:callback_url) { 'http://callback.partner.com' }

    it 'creates' do
      params = { app_version: app_version,
                 app_build: app_build,
                 app_locale: app_locale,
                 app_connectivity: app_connectivity,
                 device_hw_version: device_hw_version,
                 device_os_version: device_os_version,
                 delight_version: delight_version,
                 callback_url: callback_url }
      request.env['HTTP_X_NB_AUTHTOKEN'] = app.token
      post :create, { partner_app_session: params, format: :xml }
      response.should be_success

      xml = response.body
      xml.should have_xpath('//partner_app_session')
      xml.should have_xpath('//partner_app_session/id')
      xml.should have_xpath('//partner_app_session/recording')
      xml.should have_xpath('//partner_app_session/uploading_on_wifi_only')
      xml.should have_xpath('//partner_app_session/upload_uris')
      xml.should have_xpath('//partner_app_session/scale_factor')
      xml.should have_xpath('//partner_app_session/maximum_frame_rate')
      xml.should have_xpath('//partner_app_session/average_bit_rate')
      xml.should have_xpath('//partner_app_session/maximum_key_frame_interval')
      xml.should have_xpath('//partner_app_session/maximum_duration')
    end
  end
end

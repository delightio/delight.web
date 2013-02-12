FactoryGirl.define do
  factory :partner_app_session do |a|
    a.delight_version '3.0'
    a.app_version '1.4'
    a.app_build 'EFKJ'
    a.app_locale 'en_US'
    a.app_connectivity 'wifi'
    a.device_hw_version 'iPhone 4.1'
    a.device_os_version '5.0'
    a.callback_url 'http://callback.partner.com'
    a.created_at 1.day.ago
    a.duration 2

    a.association :app
  end
end

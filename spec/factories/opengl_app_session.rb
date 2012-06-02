FactoryGirl.define do
  factory :opengl_app_session do |a|
    a.delight_version '2.0'
    a.app_version '1.4'
    a.app_build 'EFKJ'
    a.app_locale 'en_US'
    a.app_connectivity 'wifi'
    a.device_hw_version 'iPhone 4.1'
    a.device_os_version '5.0'
    a.created_at 1.day.ago
    a.duration 2

    a.association :app

    after_build do |a|
      a.app.stub :recording? => false
    end
  end

  factory :non_recording_opengl_app_session, :parent => :opengl_app_session do
  end
end
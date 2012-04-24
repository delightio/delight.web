FactoryGirl.define do
  factory :app_session do |a|
    a.app_version '1.4'
    a.app_build 'EFKJ'
    a.delight_version '0.1'
    a.locale 'en_US'
    a.created_at 1.day.ago
    a.duration 2

    a.association :app
  end
end

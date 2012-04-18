FactoryGirl.define do
  factory :app_session do |a|
    a.app_version '1.4'
    a.delight_version '0.1'
    a.locale 'en_US'

    a.association :app
  end
end
FactoryGirl.define do
  factory :account do |a|
    a.name 'Pipely Inc.'
    administrator
    #a.association :administrator
  end

  factory :app_session do |a|
    a.app_version '1.4'
    a.delight_version '0.1'
    a.locale 'en_US'

    a.association :app
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :scheduler do
    app_id 1
    state "recording"
    wifi_only false
    scheduled 10
    recorded 1
  end
end

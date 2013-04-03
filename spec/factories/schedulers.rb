# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :scheduler do
    app_id 1
    recording true
    wifi_only false
  end
end

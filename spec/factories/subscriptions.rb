# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :subscription do |s|
    s.association :account
    s.association :quota_plan
  end

  factory :quota_subscription, :class => 'Subscription' do |s|
    s.association :account
    s.association :quota_plan
  end

  factory :time_subscription, :class => 'Subscription' do |s|
    s.association :account
    s.association :time_plan
  end
end

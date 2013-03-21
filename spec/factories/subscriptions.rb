# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :subscription do |s|
    s.association :account
    s.association :plan
  end
end

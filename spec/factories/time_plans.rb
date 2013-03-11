# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_plan do
    type "TimePlan"
    name "TimePlan"
    price 200
    duration 1.months
  end
end

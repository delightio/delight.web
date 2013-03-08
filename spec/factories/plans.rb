# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :plan do
    type ""
    name "MyString"
    price 1
    quota 1
    duration 1
  end
end

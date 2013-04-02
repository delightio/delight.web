# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment do
    stripe_customer_id "MyString"
    subscription_id 1
  end
end

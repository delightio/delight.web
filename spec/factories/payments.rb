# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment do |p|
    p.stripe_customer_id "MyString"
    p.association :subscription
  end
end

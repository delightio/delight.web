# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :quota_plan do
    type "QuotaPlan"
    name "QuotaPlan"
    price 100
    quota 100
  end

  factory :free_plan, :parent => :quota_plan do
  	type "QuotaPlan"
  	name "FreePlan"
  	price 0
  	quota 200
  end
end
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :volume_plan do
    type "VolumePlan"
    name "VolumePlan"
    price 100
    quota 1000
    duration 86400
  end
end

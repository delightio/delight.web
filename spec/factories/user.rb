# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do 
    type 'User'
  end

  factory :administrator do 
    type 'Administrator'
  end 

  factory :viewer do 
    type 'Viewer'
  end 
end

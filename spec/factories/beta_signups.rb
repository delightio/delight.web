# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :beta_signup do
    email "MyString"
    app_name "MyString"
    platform "MyString"
    opengl false
    unity3d false
  end
end

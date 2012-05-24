# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :property do
    app_session_id 1
    key "MyString"
    value "MyString"
  end
end

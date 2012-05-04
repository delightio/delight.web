# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invitation do |i|
    i.association :app
    i.app_session_id nil
    i.sequence :email do |n|
      "invitation_user_email_#{n}@example.com"
    end
    i.message nil
    #token "MyString"
    #token_expiration "2012-05-03 13:16:30"
  end
end

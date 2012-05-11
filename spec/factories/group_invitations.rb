# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group_invitation do |g|
    g.association :app
    g.app_session_id nil
    g.emails "test1@example.com, test2@example.com"
    g.message "some message"
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    signup_step 2
    type 'User'
    sequence :email do |n|
      "user_email#{n}@example.com"
    end
    sequence :nickname do |n|
      "user_nickname#{n}"
    end

    after_build do |u|
      u.stub :subscribe_to_email_list => true
    end
  end

  factory :administrator do
    signup_step 2
    type 'Administrator'
    sequence :email do |n|
      "admin_email#{n}@example.com"
    end
    sequence :nickname do |n|
      "admin_nickname#{n}"
    end

    after_build do |u|
      u.stub :subscribe_to_email_list => true
    end
  end

  factory :viewer do
    signup_step 2
    type 'Viewer'
    sequence :email do |n|
      "viewer_email#{n}@example.com"
    end
    sequence :nickname do |n|
      "viewer_nickname#{n}"
    end

    after_build do |u|
      u.stub :subscribe_to_email_list => true
    end
  end
end

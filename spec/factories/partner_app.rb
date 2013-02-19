FactoryGirl.define do
  factory :partner_app do |a|
    a.name 'Partner App'

    a.association :account
  end
end
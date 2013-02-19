FactoryGirl.define do
  factory :partner_account do |a|
    a.name 'X Inc.'
    administrator
    #a.association :administrator
  end
end
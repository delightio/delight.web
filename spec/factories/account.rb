FactoryGirl.define do
  factory :account do |a|
    a.name 'Pipely Inc.'
    administrator
    #a.association :administrator
  end
end
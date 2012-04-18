FactoryGirl.define do
  factory :app do |a|
    a.name 'Nowbox'
    a.association :account
  end
end
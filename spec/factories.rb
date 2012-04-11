FactoryGirl.define do
  factory :account do
    name 'Pipely Inc.'
  end

  factory :app do |a|
    a.name 'Nowbox'
    a.association :account
  end

  factory :app_session do |a|
    a.association :app
  end
end
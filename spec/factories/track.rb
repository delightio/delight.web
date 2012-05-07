FactoryGirl.define do
  factory :track do |t|
    t.association :app_session
   end

  factory :screen_track do |t|
  end

  factory :touch_track do |t|
  end

  factory :front_track do |t|
  end
end

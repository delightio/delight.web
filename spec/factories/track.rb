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

  factory :orientation_track do |t|
  end

  factory :event_track do |t|
  end

  factory :view_track do |t|
  end

  factory :presentation_track do |t|
  end

  factory :gesture_track do |t|
  end
end

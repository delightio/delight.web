FactoryGirl.define do
  factory :app do |a|
    a.name 'Nowbox'

    a.association :account
  end

  # Since by default app schedule to record
  factory :recording_app, :parent => :app do |a|
  end

  factory :non_recording_app, :parent => :app do |non_recording_app|
    after(:create) do |a|
      a.schedule_recordings 0
    end
  end
end
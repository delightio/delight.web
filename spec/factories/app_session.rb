FactoryGirl.define do
  factory :app_session do |a|
    a.delight_version '2.0'
    a.app_version '1.4'
    a.app_build 'EFKJ'
    a.app_locale 'en_US'
    a.app_connectivity 'wifi'
    a.device_hw_version 'iPhone 4.1'
    a.device_os_version '5.0'
    a.created_at 1.day.ago
    a.duration 2

    a.association :app

    after(:build) do |a|
      a.app.stub :recording? => false
    end
  end

  factory :non_recording_app_session, :parent => :app_session do
  end

  # NOTE that recording_app_session will trigger an external call to
  # S3 for getting presigned URI. Please use them with cautions!
  factory :recording_app_session, :class => 'AppSession' do |a|
    a.delight_version '0.1'
    a.app_version '1.4'
    a.app_build 'EFKJ'
    a.app_locale 'en_US'
    a.app_connectivity 'wifi'
    a.device_hw_version 'iPhone 4.1'
    a.device_os_version '5.0'
    a.created_at 1.day.ago
    a.duration 2

    a.association :app

    after(:build) do |a|
      a.app.stub :recording? => true
    end
  end

  # It's based on non_recording_app_session but we fake the recording state
  # by setting expected_track_count and creating fake tracks
  factory :uploaded_app_session, :parent => :non_recording_app_session do |s|
    after(:create) do |a|
      a.app.stub :recording? => true
      a.update_attribute :expected_track_count, 3
      FactoryGirl.create :screen_track, app_session: a
      FactoryGirl.create :touch_track, app_session: a
    end
  end

  factory :recorded_app_session, :parent => :uploaded_app_session do |s|
    after(:create) do |a|
      FactoryGirl.create :presentation_track, app_session: a
    end
  end
end

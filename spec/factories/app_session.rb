FactoryGirl.define do
  factory :app_session do |a|
    a.app_version '1.4'
    a.app_build 'EFKJ'
    a.delight_version '0.1'
    a.locale 'en_US'
    a.created_at 1.day.ago
    a.duration 2

    a.association :app

    after_build do |a|
      a.app.stub :recording? => false
    end
  end

  factory :non_recording_app_session, :parent => :app_session do
  end

  # NOTE that recording_app_session will trigger an external call to
  # S3 for getting presigned URI. Please use them with cautions!
  factory :recording_app_session, :class => 'AppSession' do |a|
    a.app_version '1.4'
    a.app_build 'EFKJ'
    a.delight_version '0.1'
    a.locale 'en_US'
    a.created_at 1.day.ago
    a.duration 2

    a.association :app

    after_build do |a|
      a.app.stub :recording? => true
    end
  end

  # It's based on non_recording_app_session but we fake the recording state
  # by setting expected_track_count and creating fake tracks
  factory :recorded_app_session, :parent => :non_recording_app_session do |s|
    after_create do |a|
      a.app.stub :recording? => true
      a.update_attribute :expected_track_count, 2
      a.expected_track_count.times do
        FactoryGirl.create :track, :app_session => a
      end
    end
  end
end

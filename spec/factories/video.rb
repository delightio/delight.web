FactoryGirl.define do
  factory :video do |v|
    v.association :app_session
    uri { "https://s3.amazonaws.com/delight_upload/#{app_session.id}.mp4" }
  end
end

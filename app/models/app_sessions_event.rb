class AppSessionsEvent < ActiveRecord::Base
  belongs_to :app_session, counter_cache: true
  belongs_to :event, counter_cache: true
  belongs_to :track, counter_cache: true
end

class AppSessionsEvent < ActiveRecord::Base
  belongs_to :app_session, counter_cache: true
  belongs_to :event, counter_cache: true
  belongs_to :track, counter_cache: true

  validates :app_session_id, presence: true
  validates :event_id, presence: true
  validates :track_id, presence: true

  before_validation :associate_track

private
  def associate_track
    self.track_id = app_session.event_track.id
  end
end

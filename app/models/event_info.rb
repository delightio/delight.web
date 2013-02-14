class EventInfo < ActiveRecord::Base
  belongs_to :app_session, counter_cache: true
  belongs_to :event, counter_cache: true
  belongs_to :track, counter_cache: true

  validates :app_session_id, presence: true
  validates :event_id, presence: true
  validates :track_id, presence: true

  serialize :properties, ActiveRecord::Coders::Hstore

  before_validation :associate_track

  module Scopes
    def by_properties(properties)
      properties.inject(scoped) do |query, attributes|
        query.where("properties -> ? = ?", attributes[0], attributes[1])
      end
    end
  end
  extend Scopes

private
  def associate_track
    self.track_id = app_session.event_track.id
  end
end

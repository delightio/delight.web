class Funnel < ActiveRecord::Base
  belongs_to :app
  has_many :events_funnels
  has_many :events, :through => :events_funnels

  validates :name, presence: true

  def app_sessions
    event_names = events.all.map{|e| e.name}
    AppSession.by_events(event_names)
  end
end
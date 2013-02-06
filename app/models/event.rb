class Event < ActiveRecord::Base
  has_many :app_sessions_events
  has_many :app_sessions, :through => :app_sessions_events

  module Scopes
    def by_name(names)
      if names.blank?
        scoped
      else
        where(name: names)
      end
    end

    def by_app(app)
      joins(:app_sessions => :app).where('apps.id = ?', app.id)
    end
  end
  extend Scopes
end
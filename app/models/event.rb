class Event < ActiveRecord::Base
  has_many :app_sessions_events
  has_many :app_sessions, :through => :app_sessions_events

  has_many :events_funnels
  has_many :funnels, :through => :events_funnels

  validates :name, presence: true
  validates :time, presence: true

  serialize :properties, ActiveRecord::Coders::Hstore

  module Scopes
    def by_name(names)
      name_table = arel_table[:name]
      query = names.inject(nil) do |query, name|
                fomular = name_table.eq(name)
                !query ? fomular : query.or(fomular)
              end
      where(query)
    end

    def by_app(app)
      events = joins(:app_sessions => :app).merge(App.where(id: app.id))
      events.all.uniq {|event| event.name}
    end

    def by_properties(properties)
      properties.inject(scoped) do |query, attributes|
        query.where("properties -> ? = ?", attributes[0], attributes[1])
      end
    end
  end
  extend Scopes
end
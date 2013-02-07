class Event < ActiveRecord::Base
  has_many :app_sessions_events
  has_many :app_sessions, :through => :app_sessions_events

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
      joins(:app_sessions => :app).where('apps.id = ?', app.id)
    end
  end
  extend Scopes
end
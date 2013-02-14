class Event < ActiveRecord::Base
  belongs_to :app
  has_many :event_infos, :dependent => :destroy
  has_many :app_sessions, :through => :event_infos, uniq: true

  has_many :events_funnels
  has_many :funnels, :through => :events_funnels


  validates :name, presence: true

  module Scopes
    def by_id(ids)
      name_table = arel_table[:id]
      query = ids.inject(nil) do |query, id|
                fomular = name_table.eq(id)
                !query ? fomular : query.or(fomular)
              end
      where(query)
    end

    def by_app(app)
      events = joins(:app_sessions => :app).merge(App.where(id: app.id))
      events.uniq
    end
  end
  extend Scopes
end
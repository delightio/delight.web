class Event < ActiveRecord::Base
  belongs_to :app
  has_many :event_infos, :dependent => :destroy
  has_many :app_sessions, :through => :event_infos, uniq: true

  has_many :events_funnels
  has_many :funnels, :through => :events_funnels

  validates :name, presence: true, :uniqueness => {:scope => :app_id}

  module Scopes
    def by_id(ids)
      name_table = arel_table[:id]
      query = ids.inject(nil) do |query, id|
                fomular = name_table.eq(id)
                !query ? fomular : query.or(fomular)
              end
      where(query)
    end
  end
  extend Scopes
end
class Event < ActiveRecord::Base
  belongs_to :track, counter_cache: true

  module Scopes
    def by_name(names)
      if names.blank?
        scoped
      else
        where(name: names)
      end
    end

    def by_app(app)
      joins(:track => {:app_session => :app}).where('apps.id = ?', app.id)
    end
  end
  extend Scopes
end
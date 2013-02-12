class EventsFunnel < ActiveRecord::Base
  belongs_to :event
  belongs_to :funnel
end
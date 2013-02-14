class Funnel < ActiveRecord::Base
  belongs_to :app
  has_many :events_funnels
  has_many :events, :through => :events_funnels

  validates :name, presence: true
end
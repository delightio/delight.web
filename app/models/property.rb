class Property < ActiveRecord::Base
  belongs_to :app_session

  validates_presence_of :app_session_id, :key, :value
end

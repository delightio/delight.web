class Video < ActiveRecord::Base
  belongs_to :app_session
  validates_presence_of :uri
  validates_presence_of :app_session_id
end

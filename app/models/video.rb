class Video < ActiveRecord::Base
  belongs_to :app_session
  validates_presence_of :uri
  validates_presence_of :app_session_id

  after_create {|v| app_session.complete_upload self }
end

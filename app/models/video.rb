class Video < ActiveRecord::Base
  belongs_to :app_session
  validates_presence_of :uri
  validates_presence_of :app_session_id

  after_create {|v| app_session.complete_upload self }

  def presigned_read_uri
    uploader = VideoUploader.new app_session_id
    uploader.presigned_read_uri
  end
end

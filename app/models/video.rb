class Video < ActiveRecord::Base
  belongs_to :app_session

  validates_presence_of :url
end

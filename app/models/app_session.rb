class AppSession < ActiveRecord::Base
  belongs_to :app
  has_many :videos
end

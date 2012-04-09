class App < ActiveRecord::Base
  belongs_to :account
  has_many :app_sessions
end

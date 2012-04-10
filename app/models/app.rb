class App < ActiveRecord::Base
  belongs_to :account
  has_many :app_sessions

  validates_presence_of :token
  validates_uniqueness_of :token

  before_validation :generate_token, :on => :create

  def generate_token
    self.token = SecureRandom.hex 12
  end
end
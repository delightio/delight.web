class App < ActiveRecord::Base
  belongs_to :account
  has_many :app_sessions

  before_validation :generate_token, :on => :create
  validate :token, :presence => true, :uniqueness => true

  def generate_token
    self.token = "#{SecureRandom.hex 12}#{id}"
  end

  def recording?
    true
  end

  def uploading_on_wifi_only?
    true
  end

end
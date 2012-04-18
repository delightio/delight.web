class App < ActiveRecord::Base
  belongs_to :account
  has_many :app_sessions

  has_many :permissions
  has_many :viewers, :through => :permissions 

  validates_presence_of :token
  validates_uniqueness_of :token

  before_validation :generate_token, :on => :create

  module Scopes
    def administered_by(user) 
      joins(:account).where(:accounts => { :administrator_id => user.id }) 
    end 

    def viewable_by(user)
      joins(:permissions).where(:permissions => { :viewer_id => user.id })
    end
  end
  extend Scopes

  def generate_token
    self.token = SecureRandom.hex 12
  end

  def recording?
    true
  end

  def uploading_on_wifi_only?
    true
  end

end

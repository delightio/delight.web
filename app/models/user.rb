class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable
  #devise :database_authenticatable, :registerable, :omniauthable
  devise :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :twitter_id, :github_id, :nickname, :image_url, :signup_step

  validates :nickname, :presence => true
  validates :email, :presence => true, :if => :done_registering?

  has_many :favorites
  has_many :favorite_app_sessions, :through => :favorites, :source => :app_session, :select => 'DISTINCT app_sessions.*'

  def self.find_or_create_for_twitter_oauth(auth_hash, signed_in_resouce=nil)
    uid = auth_hash['uid'].to_s
    if user = self.find_by_twitter_id(uid)
      user
    else
      user = self.create(:twitter_id => uid,
                         :nickname => auth_hash['info']['nickname'],
                         :image_url => auth_hash['info']['image'])
    end
  end

  def self.find_or_create_for_github_oauth(auth_hash, signed_in_resouce=nil)
    uid = auth_hash['uid'].to_s
    if user = self.find_by_github_id(uid)
      user
    else
      user = self.create(:github_id => uid,
                         :nickname => auth_hash['info']['nickname'],
                         :image_url => defined?(auth_hash['extra']['raw_info']['avatar_url']) ? auth_hash['extra']['raw_info']['avatar_url'] : nil)
    end
  end

  def administrator?
    self.type == 'Administrator'
  end

  def viewer?
    self.type == 'Viewer'
  end

  def done_registering?
    self.signup_step > 1
  end

end

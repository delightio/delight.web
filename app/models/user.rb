class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable
  #devise :database_authenticatable, :registerable, :omniauthable
  devise :omniauthable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :twitter_id, :github_id, :nickname, :image_url, :signup_step, :type, :twitter_url, :github_url

  validates :nickname, :presence => true
  validates :email, :presence => true, :format => /^([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})$/i, :if => :done_registering?

  after_create :subscribe_to_email_list

  has_many :favorites
  has_many :favorite_app_sessions, :through => :favorites, :source => :app_session, :select => 'DISTINCT app_sessions.*'

  def self.find_or_create_for_twitter_oauth(auth_hash, signed_in_resouce=nil, type=nil, create_email_override = nil)
    uid = auth_hash['uid'].to_s
    if user = self.find_by_twitter_id(uid)
      #if not type.nil? and not user.kind_of?(type.constantize)
      #  user.type = type
      #  user.save
      #end
      if user.twitter_url.nil?
        user.twitter_url = auth_hash['info']['urls']['Twitter']
        user.save
      end
      user
    else
      if not create_email_override.blank?
        user = self.create(:twitter_id => uid,
                           :twitter_url => auth_hash['info']['urls']['Twitter'],
                           :nickname => auth_hash['info']['nickname'],
                           :image_url => auth_hash['info']['image'],
                           :type => type ? type : 'User',
                           :email => create_email_override)
      else
        user = self.create(:twitter_id => uid,
                           :twitter_url => auth_hash['info']['urls']['Twitter'],
                           :nickname => auth_hash['info']['nickname'],
                           :image_url => auth_hash['info']['image'],
                           :type => type ? type : 'User')
      end
    end
  end

  def self.find_or_create_for_github_oauth(auth_hash, signed_in_resouce=nil, type=nil, create_email_override = nil)
    uid = auth_hash['uid'].to_s
    if user = self.find_by_github_id(uid)
      #if not type.nil? and not user.type == type
      #  user.type = type
      #  user.save
      #end
      if user.github_url.nil?
        user.github_url = auth_hash['info']['urls']['GitHub']
        user.save
      end
      user
    else
      if not create_email_override.blank?
        user = self.create(:github_id => uid,
                           :github_url => auth_hash['info']['urls']['GitHub'],
                           :nickname => auth_hash['info']['nickname'],
                           :image_url => defined?(auth_hash['extra']['raw_info']['avatar_url']) ? auth_hash['extra']['raw_info']['avatar_url'] : nil,
                           :type => type ? type : 'User',
                           :email => create_email_override)
      else
        user = self.create(:github_id => uid,
                           :github_url => auth_hash['info']['urls']['GitHub'],
                           :nickname => auth_hash['info']['nickname'],
                           :image_url => defined?(auth_hash['extra']['raw_info']['avatar_url']) ? auth_hash['extra']['raw_info']['avatar_url'] : nil,
                           :type => type ? type : 'User')
      end
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

  def profile_url
    if twitter_id
      twitter_url
    else
      github_url
    end
  end

  def subscribe_to_email_list
    # EmailNotification.subscribe email
  end
end

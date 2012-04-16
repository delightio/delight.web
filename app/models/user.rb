class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable
  devise :database_authenticatable, :registerable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :twitter_id, :github_id

  belongs_to :account
  #validates :account_id, :presence => true

  def self.find_or_create_for_twitter_oauth(auth_hash, signed_in_resouce=nil) 
    #data = access_token.extra.raw_info 
    uid = auth_hash['uid'] 
    if user = self.find_by_twitter_id(uid)
      user 
    else 
      self.create!(:twitter_id => uid) 
    end 
  end

  def self.find_or_create_for_github_oauth(auth_hash, signed_in_resouce=nil) 
    #data = access_token.extra.raw_info 
    uid = auth_hash['uid'] 
    if user = self.find_by_github_id(uid)
      user 
    else 
      self.create!(:github_id => uid) 
    end 
  end

end

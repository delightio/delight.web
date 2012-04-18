class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable
  #devise :database_authenticatable, :registerable, :omniauthable
  devise :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :twitter_id, :github_id

  def self.find_or_create_for_twitter_oauth(auth_hash, signed_in_resouce=nil) 
    #data = access_token.extra.raw_info 
    uid = auth_hash['uid'].to_s 
    if user = self.find_by_twitter_id(uid)
      user 
    else 
      user = self.create(:twitter_id => uid) 
      #user = self.new(:twitter_id => uid) 
      #user.save(:validate => false) 
      #user 
    end 
  end

  def self.find_or_create_for_github_oauth(auth_hash, signed_in_resouce=nil) 
    #data = access_token.extra.raw_info 
    uid = auth_hash['uid'].to_s 
    if user = self.find_by_github_id(uid)
      user 
    else 
      user = self.create(:github_id => uid) 
      #user = self.new(:github_id => uid) 
      #user.save(:validate => false) 
      #user 
    end 
  end

  def administrator? 
    self.type == 'Administrator' 
  end 

  def viewer? 
    self.type == 'Viewer'
  end 

end

class Invitation < ActiveRecord::Base

  TOKEN_LIFETIME = 86400 *  3 # 3 days

  belongs_to :app
  after_create :generate_token

  validates :app_id, :presence => true
  validates :email, :presence => true
  # want to allow user to create multiple invite for the same user
  #validates :email, :uniqueness => { :scope => :app_id }

  protected

  def generate_token
    update_attributes(
      :token =>  "#{SecureRandom.hex 12}#{id}",
      :token_expiration => created_at + TOKEN_LIFETIME
    )
  end
end

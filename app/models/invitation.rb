class Invitation < ActiveRecord::Base

  TOKEN_LIFETIME = 86400 *  3 # 3 days

  belongs_to :app
  belongs_to :group_invitation
  after_create :generate_token

  validates :app_id, :presence => true
  validates :email, :presence => true
  # want to allow user to create multiple invite for the same user
  #validates :email, :uniqueness => { :scope => :app_id }
  validate :valid_emails?

  protected

  def generate_token
    update_attributes(
      :token =>  "#{SecureRandom.hex 12}#{id}",
      :token_expiration => created_at + TOKEN_LIFETIME
    )
  end

  def valid_emails?
    if not self.email.nil?
      self.email.split(",").each do |email|
        if not valid_email?(email)
          errors.add(:email, "email #{email} is invalid")
        end
      end
    end
  end

  def valid_email?(email)
    email.strip =~ /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/
  end

end

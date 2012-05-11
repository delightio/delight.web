class GroupInvitation < ActiveRecord::Base
  validates :emails, :presence => true
  validates :app_id, :presence => true
  validate :validate_emails
  after_create :create_invitations
  has_many :invitations
  belongs_to :app

  protected

  def validate_emails
    if not self.emails.nil?
      self.emails.split(",").each do |email|
        if not valid_email?(email)
          errors.add(:emails, "email #{email} is invalid")
        end
      end
    end
  end

  def valid_email?(email)
    email.strip =~ /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/
  end

  def create_invitations
    ActiveRecord::Base.transaction do
      self.emails.split(",").each do |email|
        new_invitation = self.invitations.create(
          :email => email.strip,
          :message => self.message,
          :app_id => self.app_id,
          :app_session_id => self.app_session_id
        )
        if new_invitation.nil? or not new_invitation.valid?
          errors.add(:create_invitation, "Fail to create new invitation with email #{email.strip}")
          raise ActiveRecord::Rollback and return false
        end
      end
    end
  end

end

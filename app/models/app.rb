class App < ActiveRecord::Base
  belongs_to :account
  has_many :app_sessions

  has_many :permissions
  has_many :viewers, :through => :permissions, :uniq => true

  has_many :group_invitations
  has_many :invitations

  has_many :events
  has_many :funnels
  has_one :scheduler

  attr_accessible :name

  after_create :assign_admin_as_viewer
  after_create :generate_token
  after_create :schedule_recordings
  validate :token, :presence => true, :uniqueness => true
  validates :name, :presence => true

  module Scopes
    def administered_by(user)
      select('DISTINCT apps.*').joins(:account).where(:accounts => { :administrator_id => user.id })
    end

    def viewable_by(user)
      select('DISTINCT apps.*').joins(:permissions).where(:permissions => { :viewer_id => user.id })
    end
  end
  extend Scopes

  def uploading_on_wifi_only?
    scheduler.wifi_only?
  end

  def activated?
    # #any? triggers pulling in ALL app sessions.
    # app_sessions.any? &:recorded?
    app_sessions.recorded.limit(1).count > 0
  end

  def complete_recording cost=1
    account.update_usage cost
  end

  def administrator
    account.administrator
  end

  def administered_by?(user)
    administrator == user || viewable_by?(user)
  end

  def viewable_by?(user)
    self.viewers.include?(user)
  end

  def emails
    (viewers.map &:email).uniq
  end

  def last_viewed_at_by_user(user)
    permission = permissions.where(:viewer_id => user.id).first
    if permission.nil?
      nil
    else
      permission.last_viewed_at
    end
  end

  def log_view(user)
    permission = permissions.where(:viewer_id => user.id).first
    if permission.nil?
      raise "Invalid permission"
    end
    permission.last_viewed_at = Time.now
    permission.save
  end


  private
  def assign_admin_as_viewer
    viewers << administrator
  end

  def generate_token
    update_attribute :token, "#{SecureRandom.hex 12}#{id}"
  end

  def schedule_recordings
    self.scheduler = Scheduler.create app_id: id
    self.scheduler.set_wifi_only true
    self.scheduler.start_recording
  end
end

class Account < ActiveRecord::Base
  has_many :apps
  accepts_nested_attributes_for :apps
  attr_accessible :apps_attributes, :name, :administrator_id

  belongs_to :administrator
  has_many :permissions
  has_many :viewers, :through => :permissions

  has_one :subscription
  has_one :plan, :through => :subscriptions

  validates :administrator_id, :presence => true
  validates :name, :presence => true

  after_create :subscribe_free_plan, :email_new_signup

  def update_usage cost
    subscription.use cost

    # Check if we still have enough quota for future recordings.
    # If not, stop all recordings on associated apps
    unless subscription.enough_quota? 5.minutes
      handle_over_usage
    end
  end

  def handle_over_usage
    if subscription.auto_renew?
      subscription.renew
    else
      # schedulers = apps.map &:scheduler
      # schedulers.each { |sr| sr.stop_recording }
      subscription.notify
    end
  end

  def subscribe new_plan_id
    unsubscribe
    self.subscription = Subscription.create plan_id: new_plan_id, account_id: id
  end

  def unsubscribe
    subscription.destroy unless subscription.nil?
  end

  def subscribe_free_plan
    subscribe FreePlan.id
  end

  def email_new_signup
    Resque.enqueue ::NewAccountSignup, administrator.email
  end
end

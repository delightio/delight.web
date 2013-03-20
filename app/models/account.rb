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

  after_create :add_free_credits, :email_new_signup

  FreeCredits = 50
  SpecialCredits = 10

  def remaining_credits
    return 0 if subscription.nil?
    subscription.remaining
  end

  def enough_credits? n=1
    subscription.enough_quota? n
  end

  def add_credits n
    price = QuotaPlan.price n
    new_plan = QuotaPlan.customize price, n+remaining_credits
    subscription.destroy unless subscription.nil?
    self.subscription = Subscription.create plan_id: new_plan.id, account_id: id
    remaining_credits
  end

  def use_credits n=1
    unless subscribed_to_unlimited_plan?
      subscription.use n
    end
  end

  def subscribed_to_unlimited_plan?
    return false if subscription.nil?
    subscription.unlimited_plan?
  end

  def current_subscription
    subscription
  end

  def subscribe new_plan
    unsubscribe
    self.subscription = Subscription.create plan_id: TimePlan::UnlimitedMonthly.id, account_id: id
  end

  def unsubscribe
    subscription.destroy unless subscription.nil?
  end

  def add_free_credits
    add_credits FreeCredits + SpecialCredits
  end

  def email_new_signup
    Resque.enqueue ::NewAccountSignup, administrator.email
  end
end

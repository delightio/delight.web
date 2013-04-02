class Subscription < ActiveRecord::Base
  attr_accessible :account_id, :plan_id, :usage, :expired_at

  belongs_to :account
  belongs_to :plan
  has_one :payment

  validates :account_id, :presence => true
  validates :plan_id, :presence => true
  after_create :set_expired_at

  def remaining
    plan.quota - usage
  end

  def usage_percentage
    [(usage * 100 / plan.quota).floor, 3].max
  end

  def remaining_hours
    (remaining / 1.hours.to_f).round(1)
  end

  def days_till_expired
    expired_at ? ((expired_at - DateTime.now) / 1.days).floor : 0
  end

  def use n
    update_attributes usage:(self.usage + n)
  end

  def enough_quota? n
    return false if expired?
    return true if plan.unlimited?

    remaining >= n
  end

  def set_expired_at
    if plan.duration
      update_attributes expired_at:(created_at + plan.duration)
    end
  end

  def expired?
    return false if plan.duration.nil? || plan.unlimited?

    expired_at < DateTime.now
  end

  # notify user when we are close to limit
  def notify
    unless notified?
      Resque.enqueue ::SubscriptionCloseToLimit, account.administrator.email
    end
  end

  def notified?
    true
  end

  def subscribe plan, token=nil
    new_customer = payment.nil? && token
    returning_customer = !new_customer

    if new_customer
      self.payment = Payment.create_with_email_and_token(
                        account.administrator.email,
                        token,
                        id)
      save
    end

    # Returning customer wants to update card as well
    if returning_customer && token
      self.payment.card = token
    end

    self.payment.subscribe plan
    self.update_attributes plan_id: plan.id
  end
end
class Subscription < ActiveRecord::Base
  attr_accessible :account_id, :plan_id, :usage, :expired_at

  belongs_to :account
  belongs_to :plan
  has_one :payment

  validates :account_id, :presence => true
  validates :plan_id, :presence => true
  after_create :renew

  def remaining
    plan.quota - usage
  end

  def usage_percentage
    (usage * 100 / plan.quota).floor
  end

  def usage_in_hours
    usage / 1.hours
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

  def auto_renew?
    plan.auto_renew?
  end

  def renew
    if plan.duration
      update_attributes expired_at:(Time.now + plan.duration)
    end
    update_attributes usage: 0
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
    begin
      if self.payment.nil?
        self.payment = Payment.create_with_email(
                          account.administrator.email,
                          id)
      end

      if token
        self.payment.card = token
      end

      self.payment.subscribe plan
      self.update_attributes plan_id: plan.id
    rescue => e
      errors[:payment] = e.to_s
      return false
    end
  end
end
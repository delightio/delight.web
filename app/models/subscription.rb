class Subscription < ActiveRecord::Base
  attr_accessible :account_id, :plan_id, :usage, :expired_at

  belongs_to :account
  belongs_to :plan

  validates :account_id, :presence => true
  validates :plan_id, :presence => true
  after_create :set_expired_at

  def remaining
    plan.quota - usage
  end

  def use n
    update_attributes usage:(self.usage + n)
  end

  def unlimited_plan?
    plan.class == TimePlan
  end

  def enough_quota? n
    return false if expired?
    return true if unlimited_plan?

    remaining >= n
  end

  def set_expired_at
    if plan.duration
      update_attributes expired_at:(created_at + plan.duration)
    end
  end

  def expired?
    return false if plan.duration.nil? || unlimited_plan?

    expired_at < DateTime.now
  end
end
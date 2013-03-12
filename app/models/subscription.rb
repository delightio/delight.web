class Subscription < ActiveRecord::Base
  attr_accessible :account_id, :plan_id, :usage

  belongs_to :account
  belongs_to :plan

  validates :account_id, :presence => true
  validates :plan_id, :presence => true

  def remaining
    plan.quota - usage
  end

  def use n
    update_attributes usage:(self.usage + n)
  end

  def unlimited_plan?
    plan.class == TimePlan
  end
end

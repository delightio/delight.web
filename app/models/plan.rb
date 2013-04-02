class Plan < ActiveRecord::Base
  include Comparable

  attr_accessible :name, :price

  has_many :subscriptions
  has_many :accounts, :through => :subscriptions

  def unlimited?
    false
  end

  def price_in_dollars
    price / 100
  end

  def quota_in_hours
    quota / 1.hours
  end

  def duration_in_months
    duration / 1.months
  end

  def description
    period = "month"
    if duration_in_months > 1
      period = "#{duration_in_months} months"
    end
    "$#{price_in_dollars} for #{quota_in_hours} hours per #{period}"
  end

  def stripe_id
    "#{type}_#{name}"
  end

  def to_hash
    {
      name: name,
      price: price,
      description: description
    }
  end

  def <=>(another)
    price <=> another.price
  end
end
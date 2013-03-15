class QuotaPlan < Plan
  attr_accessible :quota

  # Hack to calculate the optimal price. We will retire quota plan soon
  def self.price quota
    plan100 = quota / 50
    plan50 = (quota % 50) / 20
    plan100 * 100 + plan50 * 50
  end

  def self.customize price, quota, name=""
    name = "#{quota} credits plan" if name.empty?
    QuotaPlan.find_or_create_by_price_and_quota_and_name(price, quota, name)
  end
end
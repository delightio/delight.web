PLANS = YAML.load_file("#{Rails.root}/config/payment.yml")[Rails.env]
PAYMENT_CONFIG = PLANS

# quota is in hours and duration is in days
def create_plan plan_info
  plan_info['quota'] *= 1.hours
  plan_info['duration'] *= 1.days if plan_info['duration']
  found = VolumePlan.where plan_info
  if found.empty?
    found << (VolumePlan.create plan_info)
  end
  found.first
end

# Preload volume plans
FreePlan = create_plan PLANS['free_plans'][0]
SubscriptionPlans = []
PLANS['subscription_plans'].each do |plan_info|
  SubscriptionPlans << (create_plan plan_info)
end
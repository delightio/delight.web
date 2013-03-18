PLANS = YAML.load_file("#{Rails.root}/config/payment.yml")[Rails.env]
PAYMENT_CONFIG = PLANS

# Preload volume plans
PLANS['subscription_plans'].each do |plan_info|
  # quota is in hours and duration is in days
  plan_info['quota'] *= 1.hours
  plan_info['duration'] *= 1.days
  found = VolumePlan.where plan_info
  if found.empty?
    VolumePlan.create plan_info
  end
end
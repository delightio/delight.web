PAYMENT_CONFIG = YAML.load_file("#{Rails.root}/config/payment.yml")[Rails.env]

# Preload volume plans
PAYMENT_CONFIG['subscription_plans'].each do |plan_info|
  found = VolumePlan.where plan_info
  if found.empty?
    VolumePlan.create plan_info
  end
end
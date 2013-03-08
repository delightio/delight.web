class QuotaPlan < Plan
  attr_accessible :quota
end

QuotaPlan60 = QuotaPlan.find_or_create_by_name_and_price_and_quota("Initial plan", 0, 60)

QuotaPlan20 = QuotaPlan.find_or_create_by_name_and_price_and_quota("20 credits plan", 50, 20)
QuotaPlan50 = QuotaPlan.find_or_create_by_name_and_price_and_quota("50 credits plan", 100, 50)
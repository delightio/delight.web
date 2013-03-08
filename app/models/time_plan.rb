class TimePlan < Plan
  attr_accessible :duration
end

MonthlyPlan = TimePlan.find_or_create_by_name_and_price_and_duration(
                      "Monthly plan", 200, 1.months )
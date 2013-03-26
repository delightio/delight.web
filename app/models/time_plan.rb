class TimePlan < Plan
  attr_accessible :duration

  def unlimited?
    true
  end
end
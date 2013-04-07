class TimePlan < Plan
  attr_accessible :duration

  def unlimited?
    true
  end

  def quota
    (1/0.0)
  end
end
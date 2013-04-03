class VolumePlan < Plan
  attr_accessible :duration, :quota
  # duration is in days
  # quota is in seconds
end

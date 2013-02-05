class Touch
  # UITouch.h from iOS SDK
  PHASE_BEGAN      = 0 # whenever a finger touches the surface.
  PHASE_MOVED      = 1 # whenever a finger moves on the surface.
  PHASE_STATIONARY = 2 # whenever a finger is touching the surface but hasn't moved since the previous event.
  PHASE_ENDED      = 3 # whenever a finger leaves the surface.
  PHASE_CANCELLED  = 4 # whenever a touch doesn't end but we need to stop tracking (e.g. putting device to face)

  def initialize hash
    @hash = hash
  end

  def begin?
    @hash['phase'] == PHASE_BEGAN
  end

  def time
    @hash['time']
  end
end
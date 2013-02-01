class GestureTrack < Track
  attr_reader :gestures

  def file_extension
    'json'
  end

  def convert_and_upload touch_plist
    convert touch_plist
    dump_and_upload
  end

  # Conver the given touch plist into a json containing
  def convert touch_plist
    @gestures = []
    parser = TouchTrackPlistParser.new touch_plist
    parser.touches.each do |touch|
      # TODO: only cares when a gesture began for now. We want to distingush
      #       different types of gestures later.
      if touch.begin?
        @gestures << Hash['type' => 'unknown', 'time' => touch.time]
      end
    end
  end

  def dump_and_upload
    filename = storage.filename
    json = File.new filename, 'w'
    JSON.dump @gestures, json
    storage.upload filename
  end

  def activities
    @gestures.count
  end
end

class TouchTrackPlistParser
  attr_reader :touches
  def initialize plist
    hashes = (Plist::parse_xml plist)['touches']
    @touches = hashes.map { |h| Touch.new h }
  end
end

class Touch
  # UITouch.h from iOS SDK
  BEGAN      = 0 # whenever a finger touches the surface.
  MOVED      = 1 # whenever a finger moves on the surface.
  STATIONARY = 2 # whenever a finger is touching the surface but hasn't moved since the previous event.
  ENDED      = 3 # whenever a finger leaves the surface.
  CANCELLED  = 4 # whenever a touch doesn't end but we need to stop tracking (e.g. putting device to face)

  def initialize hash
    @hash = hash
  end

  def begin?
    @hash['phase'] == BEGAN
  end

  def time
    @hash['time']
  end
end
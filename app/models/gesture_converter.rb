class GestureConverter
  attr_reader :gestures

  def initialize touch_plist
    touch_parser = TouchPlistParser.new touch_plist
    convert touch_parser.touches
  end

  def dump working_directory
    filename = "#{working_directory}/gestures_#{self.object_id}.json"
    json = File.new filename, 'w'
    JSON.dump @gestures, json
    json.close

    File.new filename
  end

  private
  def convert touches
    @gestures = [] # each convert will reset @gestures
    touches.each do |touch|
      # TODO: we do not distinguish between single tap and other gestures
      if touch.begin?
        @gestures << Hash['type' => 'unknown', 'time' => touch.time ]
      end
    end
  end
end

class TouchPlistParser
  attr_reader :touches

  def initialize plist
    hashes = (Plist::parse_xml plist)['touches']
    @touches = hashes.map { |h| Touch.new h }
  end
end
require 'json'

class OrientationTrack < Track
  def file_extension
    'plist'
  end

  def rotation duration
    return @rotation if @rotation

    file = download
    out = `majororientation -f #{file.path} -d #{duration}`
    json = JSON.parse out
    @rotation = json['rotation']
  end
end
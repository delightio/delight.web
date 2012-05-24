class VideoFile < File
  def width
    set_dimension if @width.nil?
    @width
  end

  def height
    set_dimension if @height.nil?
    @height
  end

  # https://github.com/zencoder/rvideo/blob/master/lib/rvideo/inspector.rb
  def set_dimension
    raw_response = `ffmpeg -i #{path} 2>&1`
    match = /\n\s*Stream.*Video:.*\n/.match(raw_response)
    video_stream = match[0].strip
    video_match = /Stream\s*(.*?)[,|:|\(|\[].*?\s*Video:\s*(.*?),\s*(.*?),\s*(\d*)x(\d*)/.match(video_stream)

    @width = video_match[4].to_i
    @height= video_match[5].to_i
  end
end
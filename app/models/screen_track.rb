class ScreenTrack < Track
  def file_extension
    'mp4'
  end

  def download
    file = supper
    VideoFile.new file.path # return as a video file
  end
end
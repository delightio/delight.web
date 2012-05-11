class ScreenTrack < Track
  def file_extension
    'mp4'
  end

  def download
    file = super
    VideoFile.new file.path # return as a video file
  end
end
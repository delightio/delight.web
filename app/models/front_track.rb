# Video track from front camera
class FrontTrack < Track
  def file_extension
    'mp4'
  end

  def upload local_file
    storage.upload local_file
  end
end
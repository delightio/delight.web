class GestureTrack < Track
  def file_extension
    'json'
  end

  def upload local_file
    storage.upload local_file
  end
end
class PresentationTrack < Track
  def file_extension
    'mp4'
  end

  def upload local_file
    storage.upload local_file
  end

  def thumbnail
    @thumbnail ||= Thumbnail.new "#{filename}.thumbnail.jpg"
  end
end

class Thumbnail < S3Storage
end
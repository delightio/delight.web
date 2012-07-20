class PresentationTrack < Track
  after_create { |t| app_session.complete if complete? }

  def file_extension
    'mp4'
  end

  def upload local_file
    storage.upload local_file
  end

  def thumbnail
    @thumbnail ||= Thumbnail.new "#{filename}.thumbnail.jpg"
  end

  def exists?
    storage.exists?
  end

  def complete?
    exists? && thumbnail.exists?
  end
end

class Thumbnail < S3Storage
end
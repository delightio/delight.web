class PartnerAppSession < AppSession
  validates_presence_of :callback_url
  serialize :callback_payload, Hash

  def complete
    super
    notify_partner
  end

  def notify_partner
    puts "PartnerAppSession[#{id}].notify_partner at #{callback_url} with #{to_hash}"
    RestClient.post callback_url, to_hash

  rescue => e
    puts "PartnerAppSession[#{id}].notify_parter recived error: #{e}"
  end

  def to_hash
    h = {}

    h[:created_at] = created_at
    h[:app_version] = app_version
    h[:app_build] = app_build
    h[:app_locale] = app_locale
    h[:duration] = duration.to_f
    h[:device_hw_version] = device_hw_version
    h[:device_os_version] = device_os_version
    h[:delight_version] = delight_version

    h[:gesture_track] = gesture_track.json_url
    h[:presentation_track] = presentation_track.json_url
    h[:thumbnail_url] = presentation_track.thumbnail.presigned_read_uri.to_s

    h[:callback_payload] = callback_payload

    h
  end
end
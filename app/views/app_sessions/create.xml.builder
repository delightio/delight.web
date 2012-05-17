xml.instruct!
xml.app_session do
  xml.id @app_session.id
  xml.recording @app_session.recording?
  if @app_session.recording?
    xml.uploading_on_wifi_only @app_session.uploading_on_wifi_only?
    xml.upload_uris @app_session.upload_uris
    xml.scale_factor @app_session.scale_factor
    xml.maximum_frame_rate @app_session.maximum_frame_rate
  end
end
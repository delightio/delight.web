xml.instruct!
xml.app_session do
  xml.id @app_session.id
  xml.recording @app_session.recording?
  xml.uploading_on_wifi_only @app_session.uploading_on_wifi_only?
  xml.upload_uris @app_session.upload_uris

  xml.record @app_session.recording?
  xml.wifi_transmission_only @app_session.uploading_on_wifi_only?
end
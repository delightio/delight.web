xml.instruct!
xml.app_session do
  xml.id @app_session.id
  xml.record @app_session.record?
  xml.wifi_transmission_only @app_session.wifi_transmission_only?
end
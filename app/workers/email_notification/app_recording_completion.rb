class AppRecordingCompletion < EmailNotification
  extend WithDatabaseConnection
  @queue = :email

  def self.perform app_id
    app = App.find app_id
    send_text app.emails,
      "[Delight] New sessions recorded for '#{app.name}'",
      "Please visit #{app_url app_id} to watch your newly recorded sessions.\n\n"\
      "Thank you for using our service,\n"\
      "http://delight.io\n\n"\
      "Follow us on Twitter: http://twitter.com/delightio"
  end

  def self.app_url app_id
    "http://#{ENV['ACTION_MAILER_DEFAULT_URL_HOST']}/apps/#{app_id}" # TODO should use
  end
end
class AppRecordingCompletion < EmailNotification
  extend WithDatabaseConnection
  @queue = :email

  def self.perform app_id
    app = App.find app_id
    send_individual(
      to:     app.emails.join(','),
      bcc:     'thomas@delight.io',
      subject: "[Delight] Recordings completed for '#{app.name}'",
      text:    "Your scheduled recordings for #{app.name} have been completed.\n"\
               "Please visit #{app_url app_id} to watch your newly "\
               "recorded sessions, or to schedule more recordings.\n\n"\
               "Thank you for using our service,\n"\
               "http://delight.io\n\n"\
               "Follow us on Twitter: http://twitter.com/delightio")
  end

  def self.app_url app_id
    "http://#{ENV['ACTION_MAILER_DEFAULT_URL_HOST']}/apps/#{app_id}" # TODO should use
  end
end
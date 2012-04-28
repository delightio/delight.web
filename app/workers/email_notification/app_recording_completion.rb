class AppRecordingCompletion < EmailNotification
  extend WithDatabaseConnection
  @queue = :email

  def self.perform app_id
    app = App.find app_id
    send app.emails,
      "[delight.io] New sessions recorded for '#{app.name}'",
      "Please visit #{app_url(app.id)} to watch your newly recorded sessions.\n\n"\
      "Thank you for using our service,\n"\
      "   Team delight.io\n\n"\
      "Follow us on Twitter: http://twitter.com/delightio"
  end

  def self.app_url app_id
    "http://delight.io/apps/#{app_id}"
  end
end
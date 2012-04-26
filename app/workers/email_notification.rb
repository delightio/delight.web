class EmailNotification
  extend WithDatabaseConnection
  @queue = :email

  def self.credential
    { username: ENV['MAILGUN_USERNAME'],
      password: ENV['MAILGUN_PASSWORD'] }
  end

  def self.send tos, subject, text
    data = Hash.new
    data[:from] = "Delight.io Team <team@delight.io>"
    data[:to] = tos.join ', '
    data[:subject] = subject
    data[:text] = text

    RestClient.post "https://#{credential[:username]}:#{credential[:password]}"\
    "@api.mailgun.net/v2/delightio.mailgun.org/messages", data
  end
end
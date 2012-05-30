class EmailNotification
  def self.credential
    { username: ENV['MAILGUN_USERNAME'],
      password: ENV['MAILGUN_PASSWORD'] }
  end

  def self.send_text(data)
    data.merge! from: 'team@delight.io' if data[:from].nil?
    RestClient.post "https://#{credential[:username]}:#{credential[:password]}"\
                    "@api.mailgun.net/v2/delightio.mailgun.org/messages", data
  end
end
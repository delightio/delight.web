class EmailNotification
  def self.credential
    { username: ENV['MAILGUN_USERNAME'],
      password: ENV['MAILGUN_PASSWORD'] }
  end

  def self.send_individual(data)
    data.merge! from: default_from if data[:from].nil?
    RestClient.post "https://#{credential[:username]}:#{credential[:password]}"\
                    "@api.mailgun.net/v2/delightio.mailgun.org/messages", data
  end

  def self.send_list(data, list=EmailList.users)
    if data[:to] != default_to
      puts "EmailNotification: Forcing To:(#{data[:to]}) to #{default_to}"
      data.merge! to: default_to
    end

    data[:bcc] = list[:address]
    send_individual data
  end

  def self.subscribe(email, list=EmailList.users)
    RestClient.post("https://#{credential[:username]}:#{credential[:password]}" \
                    "@api.mailgun.net/v2/lists/#{list[:address]}/members",
                    subscribed: true,
                    address: email)
  end

  def self.create_list(address, description)
    RestClient.post("https://#{credential[:username]}:#{credential[:password]}" \
                    "@api.mailgun.net/v2/lists",
                    address: address,
                    description: description)
  end

  def self.default_from
    'team@delight.io'
  end

  def self.default_to
    'team@delight.io'
  end
end

class EmailList
  def self.users
    { address: 'users@delightio.mailgun.org',
      description: 'Delight Users List' }
  end

  def self.beta
    { address: 'beta_users@delightio.mailgun.org',
      description: 'Delight Beta Users List' }
  end
end
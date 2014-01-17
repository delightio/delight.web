class NewAccountSignup < EmailNotification
  extend WithDatabaseConnection
  @queue = :email

  def self.perform new_user_email
    send_individual(
      to:      new_user_email,
      from:    'thomas@delight.io',
      bcc:     'signup@delight.io',
      subject: "Delight is shutting down",
      text:    "Thank you for your interest but Delight is shutting down.\n"\
               "Pleaes read our blog http://delight.io/blog for more info.\n\n"\
               "Thomas Pun\n"\
               "Founder & CEO\n"\
               "t: @delightio, @thomaspun" )
  end
end
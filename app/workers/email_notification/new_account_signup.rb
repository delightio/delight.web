class NewAccountSignup < EmailNotification
  extend WithDatabaseConnection
  @queue = :email

  def self.perform new_user_email
    send_email to:      new_user_email,
              from:    'thomas@delight.io',
              bcc:     'signup@delight.io',
              subject: "Welcome and Let's Delight Your Users!",
              text:    "My name is Thomas. I noticed you just signed up and thought I'd\n"\
                       "personally thank you for trying Delight!\n\n"\
                       "We'd love to help you gain deeper user insight and enhance your\n"\
                       "mobile experience. In order to help us achieve your goals, it'd be\n"\
                       "beneficial to us if you can tell us how you intend to use Delight.\n"\
                       "As a token of appreciation, I have given you some extra credits to\n"\
                       "your account for your time.\n\n"\
                       "And don't forget to email me or even call me at 1 (415) 413-7425\n"\
                       "if you have any questions about Delight.\n\n"\
                       "Thomas Pun\n"\
                       "Founder & CEO\n"\
                       "t: @delightio"
  end
end
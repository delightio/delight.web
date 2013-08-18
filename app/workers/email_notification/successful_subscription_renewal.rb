class SuccessfulSubscriptionRenewal < EmailNotification
  @queue = :email

  def self.perform admin_email, invoice_ref, amount, formatted_lines
    send_individual(
      to:      admin_email,
      from:    'thomas@delight.io',
      bcc:     'thomas@delight.io',
      subject: "[Delight] Successful subscription renewal and payment receipt",
      text:    "We have received your payment of $#{amount} for the following items:\n\n"\
               "Invoice ID: #{invoice_ref}\n#{formatted_lines}\n\n"\
               "If you have any questions, please contact us anytime.\n"\
               "Thank you for your business!\n\n"\
               "Thomas Pun\nCEO\nhttp://twitter.com/delightio")
  end
end
class SuccessfulSubscriptionRenewal < EmailNotification
  @queue = :email

  def self.perform admin_email, invoice_ref, amount, charge_card, formatted_lines
    send_individual(
      to:      admin_email,
      from:    'thomas@delight.io',
      bcc:     'thomas@delight.io',
      subject: "[Delight] Successful subscription renewal and payment receipt",
      html:    "We have received your payment of $#{amount} from your #{charge_card} for the following items:\n\n"\
               "<pre> Invoice ID: #{invoice_ref}\n"\
               "#{formatted_lines}\n\n</pre>"\
               "If you have any questions, please contact us anytime.<br>"\
               "Thank you for your business!<br><br>"\
               "Thomas Pun<br>"\
               "CEO<br>"\
               "https://twitter.com/delightio")
  end
end
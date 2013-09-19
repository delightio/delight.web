class SuccessfulSubscriptionRenewal < EmailNotification
  @queue = :email

  def self.perform admin_email, invoice_ref, amount, charge_card, charged_at, formatted_lines
    charged_date = (Time.at charged_at).strftime "%b %-d, %Y"
    send_individual(
      to:      admin_email,
      from:    'thomas@delight.io',
      bcc:     'thomas@delight.io',
      subject: "[Delight] Successful subscription renewal and payment receipt",
      html:    "We have received your payment of $#{amount} from your #{charge_card}<br>"\
               "on #{charged_date} for the following items:<br>"\
               "<pre> Invoice ID: #{invoice_ref}\n"\
               "#{formatted_lines}\n\n</pre>"\
               "If you have any questions, please contact us anytime.<br>"\
               "Thank you for your business!<br><br>"\
               "Thomas Pun<br>"\
               "CEO<br>"\
               "https://twitter.com/delightio")
  end
end
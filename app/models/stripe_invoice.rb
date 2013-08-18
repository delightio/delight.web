class StripeInvoice
  attr_reader :stripe_id
	def initialize stripe_id
    @stripe_id = stripe_id
	end

  def on_successful_payment
    self.cached_subscription.renew
    self.notify_by_email
  end

  def notify_by_email
    Resque.enqueue ::SuccessfulSubscriptionRenewal, self.admin_email,
                                                    self.stripe_id,
                                                    self.amount_due,
                                                    self.email_body
  end

  def cached_invoice
    return @invoice if @invoice

    @invoice = Stripe::Invoice.retrieve @stripe_id
  end

  def cached_payment
    return @payment if @payment

    @payment = payment.find_by_stripe_customer_id @customer_id
  end

  def cached_subscription
    return @subscription if @subscription

    @subscription = Subscription.find_by_payment_id self.payment.id
  end

  def admin_email
    self.cached_subscription.account.administrator.email
  end

  def formatted_lines
    # invoiceitems
    # prorations
    # subscriptions
    lines = ""

    self.cached_invoice.lines.invoiceitems.each do |invoiceitem|
      lines += self.format_line(invoiceitem.amount, invoiceitem.description, invoiceitem.date)
    end

    # prorations: TODO: still haven't seen one thru Stripe
    self.cached_invoice.lines.subscriptions.each do |sub|
      plan = sub.plan
      line = "Subscription to #{plan.name} ($#{plan.amount/100.0}/#{plan.interval})"
      lines += self.format_line(sub.amount, line, sub.period.start, sub.period.end)
    end

    lines
  end

  def summary
    lines = ""
    lines += "Subtotal ".rjust(80)
    lines += "#{("$"+self.subtotal.to_s).rjust(9)}\n"
    lines += "Total ".rjust(80)
    lines += "#{("$"+self.total.to_s).rjust(9)}\n"
    lines += "Starting customer balance ".rjust(80)
    lines += "#{("$"+self.starting_balance.to_s).rjust(9)}\n"
    lines += "\n"
    lines += "Amount due (USD) ".rjust(80)
    lines += "#{("$"+self.amount_due.to_s).rjust(9)}\n"
    lines
  end

  def email_body
    "#{self.formatted_lines}\n#{self.summary}"
  end

  def format_line(amount_in_cents, line, start_time_in_sec, end_time_in_sec=nil)
    time = Time.at start_time_in_sec
    start_time = time.strftime "%b %-d, %Y"
    date = start_time
    if end_time_in_sec
      time = Time.at end_time_in_sec
      end_time = time.strftime "%b %-d, %Y"
      date = "#{date} - #{end_time}"
    end
    date

    amount = "$#{amount_in_cents / 100.0}"
    " #{line.ljust(50)} #{date.rjust(27)} #{amount.to_s.rjust(9)}\n"
  end

  def amount_due
    self.cached_invoice.amount_due / 100.00
  end

  def subtotal
    self.cached_invoice.subtotal / 100.0
  end

  def total
    self.cached_invoice.total / 100.0
  end

  def starting_balance
    self.cached_invoice.starting_balance / 100.0
  end
end

class Float
  def to_s
    "%.2f" % self
  end
end
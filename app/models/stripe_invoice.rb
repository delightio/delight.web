class StripeInvoice
  attr_reader :invoice_id, :customer_id, :amount
	def initialize invoice_id, customer_id, amount, lines
    @invoice_id = invoice_id
    @customer_id = customer_id
    @amount = amount
    @lines = lines
	end

  def on_successful_payment
    self.cached_subscription.renew
    self.notify_by_email
  end

  def notify_by_email
    Resque.enqueue ::SuccessfulSubscriptionRenewal, self.admin_email,
                                                    @invoice_id,
                                                    @amount,
                                                    self.formatted_lines
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
    formatted_lines = ""
    @lines.each do |line|
      formatted_lines << line["description"]
    end
    formatted_lines
  end
end
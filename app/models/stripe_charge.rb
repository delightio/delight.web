class StripeCharge
  def initialize(stripe_id)
    @stripe_id = stripe_id
  end

  def on_succeeded
    self.invoice.on_successful_payment
  end

  def invoice_id
    self.charge.invoice
  end

  def invoice
    return @invoice if @invoice
    @invoice = StripeInvoice.new self.invoice_id,
                                 self.card_description,
                                 self.card_charged_at
  end

  def card_description
    card = self.charge.card
    "#{card.type} (last 4 digits: #{card.last4})"
  end

  def card_charged_at
    self.charge.created
  end

  def charge
    return @charge if @charge
    @charge = Stripe::Charge.retrieve @stripe_id
  end
end
class Webhook
  def initialize type, object_json
    @type = type
    @object_json = object_json
  end

  def process
    case @type
    when "charge.succeeded"
      # TODO: we should create a StripeCharge object instead
      card = @object_json['card']
      card_description = "#{card['type']} (last 4 digits: #{card['last4']})"
      stripe_invoice_id = @object_json['invoice']

      stripe_invoice = StripeInvoice.new stripe_invoice_id, card_description
      stripe_invoice.on_successful_payment
    end
  end
end
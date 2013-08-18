class Webhook
  def initialize type, object_json
    @type = type
    @object_json = object_json
  end

  def process
    case @type
    when "invoice.payment_succeeded"
      stripe_invoice = StripeInvoice.new @object_json['id']
      stripe_invoice.on_successful_payment
    else
      raise "Unsupported webhook"
    end
  end
end
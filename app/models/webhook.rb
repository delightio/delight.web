class Webhook
  def initialize type, object_json
    @type = type
    @object_json = object_json
  end

  def process
    case @type
    when "invoice.payment_succeeded"
      invoice_id = @object_json['id']
      customer_id = @object_json['customer']
      total = @object_json['total']
      lines = @object_json['lines']['data']

      stripe_invoice = StripeInvoice.new invoice_id, customer_id, total, lines
      stripe_invoice.on_successful_payment
    else
      raise "Unsupported webhook"
    end
  end
end
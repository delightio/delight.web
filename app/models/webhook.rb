class Webhook
  def initialize type, object_json
    @type = type
    @object_json = object_json
  end

  def process
    case @type
    when "charge.succeeded"
      stripe_charge = StripeCharge.new @object_json['id']
      stripe_charge.on_succeeded
    end
  end
end
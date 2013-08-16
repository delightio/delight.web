class Webhook
  def initialize type, object_json
    @type = type
    @object_json = object_json
  end

  def process
    case @type
    when "invoice.payment_succeeded"
    else
      raise "Unsupported webhook"
    end
  end
end
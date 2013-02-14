class PartnerAppSession < AppSession
  validates_presence_of :callback_url
  serialize :callback_payload, Hash

  def complete
    super
    notify_partner
  end

  def notify_partner
    puts "PartnerAppSession[#{id}].notify_partner at #{callback_url} with #{callback_payload}"
    RestClient.post callback_url, :callback_payload => callback_payload
  rescue => e
    puts "PartnerAppSession[#{id}].notify_parter recived error: #{e}"
  end
end
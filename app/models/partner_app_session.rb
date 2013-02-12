class PartnerAppSession < AppSession
  validates_presence_of :callback_url
  serialize :callback_payload, Hash

  def complete
    super
    notify_partner
  end

  def notify_partner
    RestClient.post callback_url, :callback_payload => callback_payload
  end
end
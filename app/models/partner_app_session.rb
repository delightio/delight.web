class PartnerAppSession < AppSession
  validates_presence_of :callback_url

  def complete
    super
    notify_partner
  end

  def notify_partner
    RestClient.post callback_url
  end
end
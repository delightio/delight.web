class PartnerAccount < Account
  after_create :subscribe_to_unlimited_plan

  def subscribe_to_unlimited_plan
    subscribe 'unlimited'
  end
end
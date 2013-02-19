class PartnerApp < App
  def recording?
    !recording_paused? &&
    account.enough_credits?
  end
end
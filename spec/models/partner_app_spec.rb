require 'spec_helper'

describe PartnerApp do
  subject { FactoryGirl.create :partner_app }

  describe '#recording?' do
    it 'only depends on account credits and if recording is paused'
  end
end
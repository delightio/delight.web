require 'spec_helper'

describe Video do
  subject { FactoryGirl.create :video }

  describe '#upload_completed'
  it 'updates associated app about new uploads' do
    AppSession.any_instance.should_receive :upload_completed

    subject
  end
end
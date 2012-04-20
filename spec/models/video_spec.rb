require 'spec_helper'

describe Video do
  subject { FactoryGirl.create :video }

  it 'updates associated app about new uploads' do
    AppSession.any_instance.should_receive :complete_upload

    subject
  end
end
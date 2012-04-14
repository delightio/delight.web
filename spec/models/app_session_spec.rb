require 'spec_helper'

describe AppSession do
  subject { FactoryGirl.create :app_session }

  describe '#create' do
    it 'creates presigned URI for uploading recording'
  end
end
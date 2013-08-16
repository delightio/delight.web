require 'spec_helper'

describe Webhook do
  describe '#process' do
    let(:webhook) { Webhook.new "invoice.payment_succeeded", "" }
    let(:invalid_webhook) { Webhook.new "", ""}

    it 'processes successful subscription payment' do
      lambda { webhook.process }.should_not raise_error
    end

    it 'raises error if event was not successful subscription payment' do
      lambda { invalid_webhook.process }.should raise_error
    end
  end
end
require 'spec_helper'

describe Webhook do
  describe '#process' do
    let(:webhook) { Webhook.new "charge.succeeded", {"id"=>"ch_00000000000000", "object"=>"charge", "created"=>1376638780, "livemode"=>false, "paid"=>true, "amount"=>500, "currency"=>"usd", "refunded"=>false, "card"=>{"id"=>"cc_00000000000000", "object"=>"card", "last4"=>"0005", "type"=>"American Express", "exp_month"=>4, "exp_year"=>2016, "fingerprint"=>"eeSErJzStlUFxBzq", "customer"=>"cus_00000000000000", "country"=>"US", "name"=>nil, "address_line1"=>nil, "address_line2"=>nil, "address_city"=>nil, "address_state"=>nil, "address_zip"=>nil, "address_country"=>nil, "cvc_check"=>nil, "address_line1_check"=>nil, "address_zip_check"=>nil}, "captured"=>true, "refunds"=>nil, "balance_transaction"=>"txn_00000000000000", "failure_message"=>nil, "failure_code"=>nil, "amount_refunded"=>0, "customer"=>"cus_00000000000000", "invoice"=>"in_00000000000000", "description"=>nil, "dispute"=>nil} }
    let(:invalid_webhook) { Webhook.new "", ""}

    it 'processes successful subscription payment' do
      StripeCharge.any_instance.stub(:on_succeeded).and_return(:true)
      lambda { webhook.process }.should_not raise_error
    end

    it 'does not raise error even if we do not support given type' do
      lambda { invalid_webhook.process }.should_not raise_error
    end
  end
end
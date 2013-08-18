require 'spec_helper'

describe Webhook do
  describe '#process' do
    let(:webhook) { Webhook.new "invoice.payment_succeeded", {"date"=>"1376635169", "id"=>"in_00000000000000", "period_start"=>"1373956740", "period_end"=>"1376635140", "lines"=>{"data"=>[{"id"=>"su_2P03lxzcHu9w2i", "object"=>"line_item", "type"=>"subscription", "livemode"=>true, "amount"=>"0", "currency"=>"usd", "proration"=>false, "period"=>{"start"=>"1378210522", "end"=>"1380802522"}, "quantity"=>"1", "plan"=>{"interval"=>"month", "name"=>"Free", "amount"=>"0", "currency"=>"usd", "id"=>"VolumePlan_Free", "object"=>"plan", "livemode"=>false, "interval_count"=>"1", "trial_period_days"=>nil}, "description"=>nil}], "count"=>"1", "object"=>"list", "url"=>"/v1/invoices/in_2OTrDwZaCov8J7/lines"}, "subtotal"=>"500", "total"=>"500", "customer"=>"cus_00000000000000", "object"=>"invoice", "attempted"=>true, "closed"=>true, "paid"=>true, "livemode"=>false, "attempt_count"=>"1", "amount_due"=>"500", "currency"=>"usd", "starting_balance"=>"0", "ending_balance"=>"0", "next_payment_attempt"=>nil, "charge"=>"_00000000000000", "discount"=>nil} }
    let(:invalid_webhook) { Webhook.new "", ""}

    it 'processes successful subscription payment' do
      StripeInvoice.any_instance.stub(:on_successful_payment).and_return(:true)
      lambda { webhook.process }.should_not raise_error
    end

    it 'raises error if event was not successful subscription payment' do
      lambda { invalid_webhook.process }.should raise_error
    end
  end
end
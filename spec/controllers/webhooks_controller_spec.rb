require 'spec_helper'

describe WebhooksController do
  describe '#post' do
    it 'processes valid event' do
      Webhook.any_instance.stub(:process).and_return(:true)
      post 'create', {"created"=>1326853478, "livemode"=>false, "id"=>"evt_00000000000000", "type"=>"invoice.payment_succeeded", "object"=>"event", "data"=>{"object"=>{"date"=>1376635169, "id"=>"in_00000000000000", "period_start"=>1373956740, "period_end"=>1376635140, "lines"=>{"data"=>[{"id"=>"su_2P03lxzcHu9w2i", "object"=>"line_item", "type"=>"subscription", "livemode"=>true, "amount"=>0, "currency"=>"usd", "proration"=>false, "period"=>{"start"=>1378210522, "end"=>1380802522}, "quantity"=>1, "plan"=>{"interval"=>"month", "name"=>"Free", "amount"=>0, "currency"=>"usd", "id"=>"VolumePlan_Free", "object"=>"plan", "livemode"=>false, "interval_count"=>1, "trial_period_days"=>nil}, "description"=>nil}], "count"=>1, "object"=>"list", "url"=>"/v1/invoices/in_2OTrDwZaCov8J7/lines"}, "subtotal"=>500, "total"=>500, "customer"=>"cus_00000000000000", "object"=>"invoice", "attempted"=>true, "closed"=>true, "paid"=>true, "livemode"=>false, "attempt_count"=>1, "amount_due"=>500, "currency"=>"usd", "starting_balance"=>0, "ending_balance"=>0, "next_payment_attempt"=>nil, "charge"=>"_00000000000000", "discount"=>nil}}, "webhook"=>{"created"=>1326853478, "livemode"=>false, "id"=>"evt_00000000000000", "type"=>"invoice.payment_succeeded", "object"=>"event", "data"=>{"object"=>{"date"=>1376635169, "id"=>"in_00000000000000", "period_start"=>1373956740, "period_end"=>1376635140, "lines"=>{"data"=>[{"id"=>"su_2P03lxzcHu9w2i", "object"=>"line_item", "type"=>"subscription", "livemode"=>true, "amount"=>0, "currency"=>"usd", "proration"=>false, "period"=>{"start"=>1378210522, "end"=>1380802522}, "quantity"=>1, "plan"=>{"interval"=>"month", "name"=>"Free", "amount"=>0, "currency"=>"usd", "id"=>"VolumePlan_Free", "object"=>"plan", "livemode"=>false, "interval_count"=>1, "trial_period_days"=>nil}, "description"=>nil}], "count"=>1, "object"=>"list", "url"=>"/v1/invoices/in_2OTrDwZaCov8J7/lines"}, "subtotal"=>500, "total"=>500, "customer"=>"cus_00000000000000", "object"=>"invoice", "attempted"=>true, "closed"=>true, "paid"=>true, "livemode"=>false, "attempt_count"=>1, "amount_due"=>500, "currency"=>"usd", "starting_balance"=>0, "ending_balance"=>0, "next_payment_attempt"=>nil, "charge"=>"_00000000000000", "discount"=>nil}}}}
      response.should be_success
    end

    it 'returns error otherwise' do
      post 'create', {}
      response.should_not be_success
    end
  end
end
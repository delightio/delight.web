require 'spec_helper'

describe StripeInvoice do
  subject { StripeInvoice.new mock, mock, mock}

  describe '#on_successful_payment' do
    let(:subscription) { mock.as_null_object }
    before do
      subject.stub :subscription => subscription
    end

    it 'renews subscription and notifies user' do
      subscription.should_receive :renew
      subject.should_receive :notify_by_email

      subject.on_successful_payment
    end
  end

  describe '#notify_by_email' do
    before do
      subject.stub :admin_email => mock
      subject.stub :email_body => mock
      subject.stub :amount_due => mock
      subject.stub :card_description => mock
      subject.stub :card_charged_at => mock
    end

    it 'emails user' do
      Resque.should_receive(:enqueue).with(::SuccessfulSubscriptionRenewal,
                                           subject.admin_email,
                                           subject.stripe_id,
                                           subject.amount_due,
                                           subject.card_description,
                                           subject.card_charged_at,
                                           subject.email_body)

      subject.notify_by_email
    end
  end

  describe '#admin_email' do
    it 'returns email associated with its subscription'
  end

  describe '#formatted_lines' do
    it 'formats line items'
  end

  describe '#amount_due' do
    it 'returns amount due (to be charged)'
  end
end
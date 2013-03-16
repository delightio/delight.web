require 'spec_helper'

describe AmazonCredential do
  subject { AmazonCredential.new }

  describe '#get' do
    it 'uses cached value when it can' do
      subject.instance_variable_get(:@cached).should_receive(:get).
        and_return({a:10, b:20})
      AWS::STS::Policy.should_not_receive :new

      subject.get
    end

    it 'cache newly obtained credentials' do
      subject.instance_variable_get(:@cached).should_receive(:get).
        and_return({})
      subject.instance_variable_get(:@cached).should_receive :set
      subject.should_receive(:session).and_return(mock.as_null_object)

      subject.get
    end
  end

  describe '#session' do
    it 'sets up the policy'
    it 'creates a new federated session'
  end
end
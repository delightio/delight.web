require 'spec_helper'

describe AmazonCredential do
  subject { AmazonCredential.new }

  describe '#get' do
    it 'uses cached value when it can' do
      subject.instance_variable_get(:@credentials).stub :expired? => false
      subject.instance_variable_get(:@credentials).should_receive :get
      AWS::STS::Policy.should_not_receive :new

      subject.get
    end

    it 'cache newly obtained credentials' do
      subject.instance_variable_get(:@credentials).stub :expired? => true
      subject.instance_variable_get(:@credentials).should_receive :set
      subject.should_receive(:session).and_return(mock.as_null_object)

      subject.get
    end
  end

  describe '#session' do
    it 'sets up the policy'
    it 'creates a new federated session'
  end
end

describe CachedHash do
  subject { CachedHash.new key, ttl}
  let(:key) { "a key" }
  let(:ttl) { 10 }
  let(:content) { {a: 1, b: 2} }

  context 'when given key has not expired' do
    before do
      existing = CachedHash.new key, ttl
      existing.set content
    end

    it 'respects remaining ttl' do
      subject = CachedHash.new key, 10*ttl

      subject.should_not be_expired
      subject.ttl.should <= ttl
    end
  end

  describe '#expired?' do
    it 'is true when key does not exist' do
      subject.should be_expired
    end

    it 'is false if TTL is larger than given input' do
      subject.stub :ttl => 10

      subject.should_not be_expired
    end
  end

  describe '#set' do
    it 'sets values to key' do
      REDIS.should_receive(:hmset).with(key, :blah, 123)

      subject.set blah: 123
    end

    it 'sets an expirary time' do
      REDIS.should_receive(:expire).with(key, ttl)

      subject.set blah:123
    end

    it 'returns values set' do
      subject.set(blah:123).should == { "blah" => "123" }
    end
  end

  describe '#get' do
    it 'reads from Redis' do
      REDIS.should_receive(:hgetall).with(key)
      subject.get
    end
  end
end

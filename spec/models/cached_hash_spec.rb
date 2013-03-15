require 'spec_helper'

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

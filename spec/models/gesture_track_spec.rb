require 'spec_helper'

describe GestureTrack do
  subject { GestureTrack.new :app_session_id => 10 }
  let(:plist) { mock }

  describe '#convert_and_upload' do
    it 'converts and uploads' do
      subject.should_receive(:convert).with(plist)
      subject.should_receive(:dump_and_upload)

      subject.convert_and_upload plist
    end
  end

  describe '#convert' do
    it 'detects single taps'
    it 'detects multi touch gestures'
    it 'detects swipes'
  end

  describe '#dump_and_upload' do
    it 'converts to json as a local file and upload'
  end
end
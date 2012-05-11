require 'spec_helper'

describe VideoFile do
  let(:filename) { File.join Rails.root, 'Procfile' }
  subject { VideoFile.new filename }

  describe '#set_dimension' do
    it 'returns width and height'
  end

  describe '#width' do
    it 'trigges set_dimension if not set' do
      subject.should_receive(:set_dimension).once

      subject.width
    end
  end

  describe '#height' do
    it 'trigges set_dimension if not set' do
      subject.should_receive(:set_dimension).once

      subject.height
    end
  end
end
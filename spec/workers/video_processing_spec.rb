require 'spec_helper'

describe VideoProcessing do
  subject { VideoProcessing }

  describe '.perform' do
    let(:app_session) { FactoryGirl.create :uploaded_app_session }
    it 'downloads to local, process, and creates new presentation track'
  end

  describe '.enqueue' do
    let(:app_session_id) { 10 }
    it 'enqueues given job on Resque' do
      Resque.should_receive(:enqueue).with(VideoProcessing, app_session_id)

      subject.enqueue app_session_id
    end
  end

  let(:screen_file) { File.new File.join Rails.root, '.gitignore' }
  let(:touch_file) { screen_file } # doesn't matter
  describe '.draw_touch' do
    it 'combines given touch and screen file'
    it 'outputs a File object' do
      (subject.draw_touch touch_file, screen_file).
        should be_an_instance_of(File)
    end
  end

  describe '.thumbnail' do
    it 'generates thumbnail from given video file'
    it 'outputs a File object'
  end

  describe '.cleanup' do
    let(:working_directory) { mock }
    it 'removes working directory and all content' do
      FileUtils.should_receive(:remove_dir).
        with(working_directory, true)

      subject.cleanup working_directory
    end
  end
end
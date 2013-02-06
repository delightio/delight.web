require 'spec_helper'

describe GestureConverter do
  let(:plist_filename) { "#{Rails.root}/spec/files/touchtrack.plist" }
  let(:truth_gestures) { [ {"type"=>"unknown", "time"=>2.91495916666463},
                           {"type"=>"unknown", "time"=>3.2261654996545985},
                           {"type"=>"unknown", "time"=>3.658171124639921},
                           {"type"=>"unknown", "time"=>4.138445499702357},
                           {"type"=>"unknown", "time"=>4.729999416624196},
                           {"type"=>"unknown", "time"=>5.993870916659944},
                           {"type"=>"unknown", "time"=>8.288586291717365},
                           {"type"=>"unknown", "time"=>12.725172207690775},
                           {"type"=>"unknown", "time"=>13.772471249685623},
                           {"type"=>"unknown", "time"=>16.700216666678898},
                           {"type"=>"unknown", "time"=>17.923294374602847},
                           {"type"=>"unknown", "time"=>18.91538141667843},
                           {"type"=>"unknown", "time"=>19.97114729171153}] }
  subject { GestureConverter.new plist_filename }

  describe '#new' do
    it 'converts touches into @gestures' do
      subject.gestures.should == truth_gestures
    end
  end

  describe '#dump' do
    let(:working_directory) { '/tmp' }

    it 'converts to json' do
      file = mock.as_null_object
      File.stub(:new).and_return(file)
      JSON.should_receive(:dump).with(subject.gestures, file)

      subject.dump working_directory
    end

    it 'returns file object' do
      subject.dump(working_directory).should be_a_kind_of(File)
    end
  end
end
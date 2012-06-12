require 'spec_helper'

describe OpenglAppSession do
  subject { FactoryGirl.create :opengl_app_session }
  its(:maximum_frame_rate) { should == 5 }
end
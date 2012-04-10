require 'spec_helper'

describe Video do
  let(:path) { "abc/jkj/kjlkj.mp4" }
  subject { Video.create path: path }

  its(:path) { should_not be_empty }
end
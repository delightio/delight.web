require 'spec_helper'

describe Video do
  let(:uri) { "abc/jkj/kjlkj.mp4" }
  subject { Video.create uri: uri }

  its(:uri) { should_not be_empty }
end
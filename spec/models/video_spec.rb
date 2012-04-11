require 'spec_helper'

describe Video do
  let(:url) { "abc/jkj/kjlkj.mp4" }
  subject { Video.create url: url }

  its(:url) { should_not be_empty }
end
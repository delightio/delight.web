require 'spec_helper'

describe UsabilityAppSession do
  subject { FactoryGirl.create :usability_app_session }
  its(:include_front_track?) { should be_true }
end
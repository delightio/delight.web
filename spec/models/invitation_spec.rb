require 'spec_helper'

describe Invitation do
  let(:invitation) { FactoryGirl.create(:invitation) }
  let(:invitation2) { FactoryGirl.create(:invitation) }

  describe "validation" do
    it "should generate token and expiration" do
      invitation.token.should_not be_nil
      invitation.created_at.should_not be_nil
      invitation.token_expiration.should == invitation.created_at + Invitation::TOKEN_LIFETIME
    end

    it "should require email" do
      invitation.email = nil
      invitation.should have(1).error_on(:email)
    end

#    it "should require unique email on same app id" do
#      invitation.app_id = 1
#      invitation.email = 'test@example.com'
#      invitation2.app_id = 1
#      invitation2.email = 'test@example.com'
#      invitation.valid?
#      puts invitation.errors.to_yaml
#      invitation.should have(1).error_on(:email)
#      invitation2.should have(1).error_on(:email)
#    end
  end # end validation

end

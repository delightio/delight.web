require 'spec_helper'

describe GroupInvitation do
  let(:group_invitation) { FactoryGirl.create(:group_invitation) }

  describe "validation" do
    it "should validate email address" do
      group_invitation.emails = '   abc@example.com   ,   bbc@example.com  '
      group_invitation.should have(0).error_on(:emails)
      group_invitation.emails = 'abc@example.com,'
      group_invitation.should have(0).error_on(:emails)
      group_invitation.emails = 'abc@exmapl.com,asdfasdfd'
      group_invitation.should have(1).error_on(:emails)
      group_invitation.emails = 'asdfa, example@exmple.com'
      group_invitation.should have(1).error_on(:emails)
      group_invitation.emails = 'asdfa, asdf'
      group_invitation.should have(2).error_on(:emails)
    end

    it "should create invitation on create" do
      invitations = group_invitation.invitations.all
      invitations.should have(2).items
      invitations.first.email.should == 'test1@example.com'
      invitations.second.email.should == 'test2@example.com'
      invitations.first.message.should == 'some message'
      invitations.second.message.should == 'some message'
    end
  end
end

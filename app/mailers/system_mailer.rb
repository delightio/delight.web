class SystemMailer < ActionMailer::Base
  default from: "team@delight.io"

  def invitation_email(user, invitation)
    @user = user
    @invitation = invitation
    @invitation_url = url_for(:controller => "invitations", :action => "show", :token => @invitation.token, :id => @invitation.id, :email => @invitation.email)
    mail(:to => invitation.email, :subject => "#{@user.nickname} invited you to delight.io")
  end
end

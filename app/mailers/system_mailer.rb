class SystemMailer < ActionMailer::Base
  default from: "system@delightio.com"

  def invitation_email(user, invitation)
    @user = user
    @invitation = invitation
    @invitation_url = url_for(:controller => "invitations", :action => "show", :token => @invitation.token, :id => @invitation.id)
    mail(:to => invitation.email, :subject => 'You are invited to delighio')
  end
end

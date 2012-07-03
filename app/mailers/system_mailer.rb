class SystemMailer < ActionMailer::Base
  default from: "team@delight.io"

  def invitation_email(user, invitation)
    @user = user
    @invitation = invitation
    @invitation_url = url_for(:controller => "invitations",
                              :action => "show",
                              :token => @invitation.token,
                              :id => @invitation.id,
                              :email => @invitation.email)
    mail(:to => invitation.email,
         :subject => "[Delight] #{@user.nickname}'s invitation to #{@invitation.app.name}")
  end

  def unsubscribe_notification(account)
    @account = account
    mail(:to => "victor@primitus.com", :subject => "[Delight] Account #{account.name} (id: #{account.id}) Unsubscription")
  end
end

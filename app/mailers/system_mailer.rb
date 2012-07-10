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

  def ios_version_notification(app, ios_version_number)
    @app = app
    @administrator = app.administrator
    @ios_version_number = ios_version_number
    mail(:to => @administrator.email,
         :subject => "[Delight] #{app.name}'s iOS SDK Upgrade Required")
  end
end

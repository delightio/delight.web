class Users::OmniauthCallbacksController < ApplicationController
  skip_before_filter :check_user_registration

  def twitter
    user_type = determine_type
    @user = User.find_or_create_for_twitter_oauth(auth_hash, current_user, user_type, determine_email)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_session_path
    end
  end

  def github
    user_type = determine_type
    @user = User.find_or_create_for_github_oauth(auth_hash, current_user, user_type, determine_email)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Github"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_session_path
    end
  end

  def passthru
     render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
    # Or alternatively,
    # raise ActionController::RoutingError.new('Not Found')
  end

  protected

  def auth_hash
    request.env["omniauth.auth"]
  end

  def determine_type
    if session['omniauth.viewer'] == true
      type = 'Viewer'
    else
      type = 'Administrator'
    end
    session['omniauth.viewer'] = nil
    type
  end

  def determine_email
    if not session['omniauth.email'].blank?
      email = session['omniauth.email']
    else
      email = nil
    end
    session['omniauth.email'] = nil
    email
  end

end


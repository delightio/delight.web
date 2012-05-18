class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_user_registration

  def after_sign_in_path_for(resource)
    if session[:credit]
      plan = session[:credit]
      session[:credit] = nil
      apps_path({:credit => plan})
    else
      apps_path
    end
  end

  protected

  def not_found
    #raise ActionController::RoutingError.new('Not Found')
    render :controller => :home, :action => :'404'
  end

  def allow_only_html_requests
    if params[:format] && params[:format] != "html"
      not_found
    end
  end

  # require user to complete profile before proceed
  def check_user_registration
    if not user_signed_in?
      return
    end

    redirect_path = current_user.administrator? ? user_signup_info_edit_path(current_user) : edit_user_path(current_user)

    if not current_user.done_registering?
      redirect_to redirect_path
      return
    end

    if current_user.administrator?
      admin = current_user.becomes(current_user.type.constantize)
      if admin.account.nil? or admin.account.apps.blank?
        redirect_to redirect_path
        return
      end
    end

    if session['omniauth.redirect']
      redirect_to session['omniauth.redirect']
      session['omniauth.redirect'] = nil
      return
    end
  end

end

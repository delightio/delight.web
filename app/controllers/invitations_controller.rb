class InvitationsController < ApplicationController
  before_filter :check_token
  before_filter :auth_viewer!

  def show
    @invitation = get_invitation(params[:id], params[:token])
    if not @invitation
      respond_to do |format|
        format.html do
          redirect_to(apps_path) and return
        end
      end
    end
  end

  def accept
    @invitation = get_invitation(params[:invitation_id], params[:token])
    if not @invitation
      respond_to do |format|
        format.html do
          logger.debug "no invitation"
          redirect_to(apps_path) and return
        end
      end
    end

    # add app-session-id in shared session if necessary
    @invitation.app.viewers << @current_viewer

    @invitation.token_expiration = Time.now
    @invitation.save

    respond_to do |format|
      format.html do
        flash[:notice] = 'Successfully accepted invitation'
        redirect_to(app_path(@invitation.app.to_param)) and return
      end
    end
  end

  protected

  def check_token
    if params[:token].blank?
      respond_to do |format|
        format.html do
          flash[:type] = 'error'
          flash[:notice] = 'Token missing'
          redirect_to(apps_path) and return
        end
      end
    end
  end

  def auth_viewer!
    # session variable used by omniauth
    if not user_signed_in?
      session['omniauth.viewer'] = true
      session['omniauth.redirect'] = invitation_path(:id => params[:id], :token => params[:token])
      authenticate_user!
    else
      #current_user.type = 'Viewer' if current_user.type == 'User'
      #current_user.save
      @current_viewer = current_user.becomes(current_user.type.constantize)
    end
  end

  def get_invitation(id, token)
    invitation = Invitation.find_by_id_and_token(id, token)
    if invitation.blank?
      respond_to do |format|
        format.html do
          flash[:type] = 'error'
          flash[:notice] = 'Invalid request'
          return nil
        end
      end
    end

    if invitation.token_expiration < Time.now
      respond_to do |format|
        format.html do
          flash[:type] = 'error'
          flash[:notice] = 'Token expired'
          return nil
        end
      end
    end

    invitation
  end

end

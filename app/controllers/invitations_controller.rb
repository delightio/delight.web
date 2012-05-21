class InvitationsController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :create]
  before_filter :check_token, :except => [:new, :create]
  before_filter :auth_viewer!, :except => [:new, :create]
  layout 'iframe', :only => [:new, :create]

  def new
    if not current_user.administrator?
      respond_to do |format|
        flash[:type] = 'error'
        flash[:notice] = 'Invalid operation'
        format.html do
          redirect_to(apps_path) and return
        end
      end
    end

    @app = App.administered_by(current_user).find_by_id(params[:app_id])
    if @app.nil?
      respond_to do |format|
        flash[:type] = 'error'
        flash[:notice] = 'Invalid operation'
        format.html do
          redirect_to(apps_path) and return
        end
      end
    end
    @group_invitation = @app.group_invitations.new(:message => "I would like to invite you to view the user sessions of my app, #{@app.name}, on Delight.")
    @group_invitation.app_id = params[:app_id]

    respond_to do |format|
      format.html
    end
  end

  def create
    if not current_user.administrator?
      respond_to do |format|
        format.json do
          render :json => {
            "result" => "fail",
            "reason" => "user is not administrator"
          }
          return
        end
        format.html do
          flash[:type] = "error"
          flash[:notice] = "User is not adminstrator"
          redirect_to :action => :new, :app_id => params[:group_invitation][:app_id]
          return
        end
      end
    end

    @app = App.administered_by(current_user).find_by_id(params[:group_invitation][:app_id])
    if @app.nil?
      respond_to do |format|
        format.json do
          render :json => {
            "result"=>"fail",
            "reason" => "invalid app id"
          }
          return
        end
        format.html do
          flash[:type] = "error"
          flash[:notice] = "Invalid app id"
          redirect_to :action => :new, :app_id => params[:group_invitation][:app_id]
          return
        end
      end
    end

    @group_invitation = @app.group_invitations.build(params[:group_invitation])
    respond_to do |format|
      if @group_invitation.save
        @group_invitation.invitations.each do |invitation|
          SystemMailer.invitation_email(current_user, invitation).deliver
        end
        format.json { render :json => { "result" => "success" } }
        format.html do
          flash[:notice] = "Succesfully created invitation"
          redirect_to :action => :new, :app_id => params[:group_invitation][:app_id]
        end
      else
        format.json { render :json =>
            { "result" => "fail",
              "reason" => "Cannot create new invitation" }
        }
        format.html do
          flash[:type] = "error"
          flash[:notice] = "Cannot create new invitation"
          render :action => :new, :app_id => params[:group_invitation][:app_id]
        end
      end
    end

  end

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
      session['omniauth.email'] = params[:email] if params[:email]
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

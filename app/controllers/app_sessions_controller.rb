class AppSessionsController < ApplicationController
  # GET /app_sessions
  # GET /app_sessions.json
  def index
    @app_sessions = AppSession.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @app_sessions }
    end
  end

  # GET /app_sessions/1
  # GET /app_sessions/1.json
  def show
    @app_session = AppSession.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @app_session }
    end
  end

  # # GET /app_sessions/new
  # # GET /app_sessions/new.json
  # def new
  #   @app_session = AppSession.new

  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.json { render json: @app_session }
  #   end
  # end

  # # GET /app_sessions/1/edit
  # def edit
  #   @app_session = AppSession.find(params[:id])
  # end

  # POST /app_sessions
  # POST /app_sessions.json
  def create
    as_params = params[:app_session]
    @app = App.find_by_token(as_params.delete :app_token)
    if @app.nil?
      render json: "Missing App Token", status: :bad_request
      return
    end
    as_params.merge! app_id: @app.id
    @app_session = AppSession.new as_params

    if @app_session.save
      render json: @app_session, status: :created
    else
      render json: @app_session.errors, status: :bad_request
    end
  end

  # PUT /app_sessions/1
  # PUT /app_sessions/1.json
  def update
    @app_session = AppSession.find(params[:id])
    as_params = params[:app_session]

    # TODO: This seems fishy and maybe we should have the iOS to create
    # a video resource (and later gesture resource) before we update the
    # app session.
    if as_params.has_key? :video_uri
      video = Video.create uri: as_params[:video_uri],
                           app_session_id: @app_session.id
      as_params.delete :video_uri
    end

    if @app_session.update_attributes(as_params)
      head :no_content
    else
      render json: @app_session.errors, status: :unprocessable_entity
    end
  end

  # DELETE /app_sessions/1
  # DELETE /app_sessions/1.json
  def destroy
    @app_session = AppSession.find(params[:id])
    @app_session.destroy

    respond_to do |format|
      format.html { redirect_to app_sessions_url }
      format.json { head :no_content }
    end
  end
end

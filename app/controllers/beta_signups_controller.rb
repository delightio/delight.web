class BetaSignupsController < ApplicationController
  # POST /beta_signups.json
  def create
    @beta_signup = BetaSignup.new(params[:beta_signup])

    respond_to do |format|
      if @beta_signup.save
        format.json { render json: @beta_signup, status: :created }
      else
        format.json { render json: @beta_signup.errors, status: :unprocessable_entity }
      end
    end
  end
end

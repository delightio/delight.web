class WebhooksController < ApplicationController
  def create
    begin
      event_json = JSON.parse(request.body.read)
      webhook = Webhook.new event_json["type"], event_json["data"]
      webhook.process
      render nothing: true

    rescue
      render status: :error
    end
  end
end
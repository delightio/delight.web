class WebhooksController < ApplicationController
  def create
    event_json = JSON.parse(request.body.read)
    puts event_json.inspect

    render status: :ok
  end
end
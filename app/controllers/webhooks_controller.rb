class WebhooksController < ApplicationController
  def create
    begin
      webhook_json = params['webhook']
      webhook = Webhook.new webhook_json['type'], webhook_json['data']['object']
      webhook.process
      render nothing: true, status: :ok
    rescue => e
      puts "Webhooks error: #{e.inspect}"
      render nothing:true, status: :error
    end
  end
end
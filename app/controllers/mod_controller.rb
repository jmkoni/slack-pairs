class ModController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook_signature, only: :create

  def create
    Slack::Client.send_mod_message(
      user_id: params[:user_id],
      channel_id: params[:channel_id],
      text: params[:text]
    )

    head :accepted
  end

  def verify_webhook_signature
    slack_request = ::Slack::Events::Request.new(request)
    return head :forbidden unless slack_request.verify!
  end
end

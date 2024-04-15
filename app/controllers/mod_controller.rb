# Accepts webhooks from slack to post messages from users to the mod channel
class ModController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook_signature, only: :create

  # Takes in params from webhook and sends a message to the mod channel
  #
  # @return [Status Code] should return a 202
  def create
    Slack::Client.send_mod_message(
      user_id: params[:user_id],
      channel_id: params[:channel_id],
      channel_name: params[:channel_name],
      text: params[:text]
    )

    head :accepted
  end

  # Validates that webhook actually comes from slack
  #
  # @return [Status Code] 403 if not verified
  def verify_webhook_signature
    slack_request = ::Slack::Events::Request.new(request)
    head :forbidden unless slack_request.verify!
  end
end

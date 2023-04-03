# Accepts webhooks from slack so users can add themselves to private channels
class ChannelsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook_signature, only: :create

  # Takes in params from webhook and adds user to channel
  #
  # @return [Status Code] should return a 202
  def create
    Slack::Client.add_user_to_channel(
      user_id: params[:user_id],
      channel_id: params[:channel_id],
      channel_name: params[:text]
    )

    head :accepted
  end

  # Validates that webhook actually comes from slack
  #
  # @return [Status Code] 403 if not verified
  def verify_webhook_signature
    slack_request = ::Slack::Events::Request.new(request)
    return head :forbidden unless slack_request.verify!
  end
end

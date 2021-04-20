module Slack
  class Client
    attr_reader :client

    def self.get_channel_users(client: nil)
      client ||= default_client
      members = client.conversations_members(
        channel: ENV["PAIR_CHANNEL"],
        limit: 10000
      )
      members.members
    end

    def self.create_conversation(pair:)
      client ||= default_client
      conv = client.conversations_open(users: pair.join(","))
      client.chat_postMessage(
        channel: conv.channel.id,
        blocks: SlackMessage.pair_message(pair: pair)
      )
    end

    private

    def self.default_client
      ::Slack::Web::Client.new(token: ENV["SLACK_OAUTH_TOKEN"])
    end
  end
end

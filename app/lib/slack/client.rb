module Slack
  class Client
    attr_reader :client

    def self.get_channel_users(client: nil)
      client = client || default_client
      members = client.conversations_members(
        channel: ENV['PAIR_CHANNEL'],
        limit: 10000
      )
      members.members
    end

    def self.create_conversation(pair:, total_pairs:)
      client = client || default_client
      conv = client.conversations_open(users: pair.join(","))
      client.chat_postMessage(
        channel: conv.channel.id,
        text: "You've both been paired up for a coffee chat! Find a time to meet (Calendly is great for this) and have fun!"
      )
    end

    private
    def self.default_client
      ::Slack::Web::Client.new(token: ENV['SLACK_OAUTH_TOKEN'])
    end
  end
end

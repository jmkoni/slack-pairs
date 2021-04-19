module Slack
  class Client
    attr_reader :client

    def self.get_channel_users(client: nil)
      client = client || default_client
      client.conversations_members(
        channel: 'C01ULEMNG0Z',
        limit: 10000
      )
    end

    def self.create_conversation(pair:)
      client = client || default_client
      conv = client.conversations_open(users: pair.join(","))
      client.chat_postMessage(
        channel: conv.channel.id,
        text: "You've both been paired up for a coffee chat! Find a time to meet (Calendly is great for this) and have fun!"
      )
    end

    def conversation(pairs:)
      client = client || default_client
      pairs.each do |pair|
        conv = client.conversations_open(users: pair.join(","))
        client.chat_postMessage(
          channel: conv.channel.id,
          text: "You've both been paired up for a coffee chat! Find a time to meet (Calendly is great for this) and have fun!"
        )
      end
    end
    def pair_members(members:)
      pairs = []
      while members.size < 3
        temp_pair = all_members.sample(2)
        pairs << temp_pair
        temp_pair.each { |pair| all_members.delete(pair) }
      end
      pairs << all_members.to_a
      pairs
    end

    def conversation(pairs:)
      client = client || default_client
      pairs.each do |pair|
        conv = client.conversations_open(users: pair.join(","))
        client.chat_postMessage(
          channel: conv.channel.id,
          text: "You've both been paired up for a coffee chat! Find a time to meet (Calendly is great for this) and have fun!"
        )
      end
    end

    private
    def default_client
      ::Slack::Web::Client.new(token: ENV['SLACK_OAUTH_TOKEN'])
    end
  end
end

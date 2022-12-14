# Internal client that makes calls out to the [SlackWebClient](https://github.com/slack-ruby/slack-ruby-client)
module Slack
  class Client
    attr_reader :client

    # Gets users from a given channel
    #
    # @param channel_id [String] ID of the channel, ex: "C182938", found by looking at the URL when viewing a channel through a browser
    # @param client [Slack::Web::Client] the slack web client, defaults to nil
    # @return [Array of Strings] array of channel users, ex: ["U1234", "U2345", "U3456"]
    def self.get_channel_users(channel_id:, client: nil)
      client ||= default_client # if nil, set = to default
      members = client.conversations_members(
        channel: channel_id,
        limit: 10_000
      )
      members.members.reject { |m| m == "U02F2U3RQKS" } # reject channitor!
    end

    # Creates conversations for a group. Conversation must first be initialized and then the channel id for that conversation should get passed in to `postMessage`
    #
    # @param group [Array of Strings] array of group users, ex: ["U1234", "U2345", "U3456"]
    # @param type [Symbol] type of conversation, currently handles :pairing and :groups
    # @param message [JSON] can be passed in, must follow the Slack Block Kit format, defaults to nil
    def self.create_conversation(group:, type:, message: nil)
      message = generate_message(group: group, type: type, message: message)
      client ||= default_client
      conv = client.conversations_open(users: group.join(","))
      client.chat_postMessage(
        channel: conv.channel.id,
        blocks: message
      )
    end

    # Given a user id, channel, and message text, it posts a message to the mod channel.
    #
    # @param user_id [String] slack user id of user who sent the message
    # @param channel_id [String] slack channel id where the user initially typed /mods
    # @param text [String] message text from user to mods
    def self.send_mod_message(user_id:, channel_id:, text:)
      client ||= default_client
      client.chat_postMessage(
        channel: ENV["MOD_CHANNEL"],
        blocks: SlackMessage.mod_message(user_id: user_id, channel_id: channel_id, text: text)
      )
    end

    private_class_method

    # Given a group and a group type, returns the correct message
    #
    # @param group [Array of Strings] array of group users, ex: ["U1234", "U2345", "U3456"]
    # @param type [Symbol] type of conversation, currently handles :pairing and :groups
    # @param message [JSON] can be passed in, must follow the Slack Block Kit format, defaults to nil
    # @return [JSON] message following the Slack Block Kit format
    def self.generate_message(group:, type:, message: nil)
      case type
      when :pairing
        SlackMessage.pair_message(pair: group)
      when :groups
        SlackMessage.groups_message(group: group)
      else
        message
      end
    end

    def self.default_client
      ::Slack::Web::Client.new(token: ENV["SLACK_OAUTH_TOKEN"])
    end
  end
end

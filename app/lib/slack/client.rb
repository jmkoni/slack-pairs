# Internal client that makes calls out to the [SlackWebClient](https://github.com/slack-ruby/slack-ruby-client)
module Slack
  class Client
    attr_reader :client

    # Gives user ability to add themselves to a private channel
    #
    # @param channel_name [String] text name of channel (ex: "_general")
    # @param user_id [String] slack user id of user who sent the message
    # @param channel_id [String] ID of the channel, ex: "C182938", found by looking at the URL when viewing a channel through a browser
    # @param client [Slack::Web::Client] the slack web client, defaults to nil
    def self.add_user_to_channel(user_id:, channel_id:, current_channel_name:, channel_name:, client: nil)
      client ||= default_client # if nil, set = to default
      channel_name = channel_name.downcase.sub("-", "_").to_sym
      begin
        if channel_name == :help
          post_ephemeral(
            channel_id: channel_id,
            user_id: user_id,
            channel_name: current_channel_name,
            client: client,
            blocks: SlackMessage.help_message
          )
        elsif SlackMessage::CHANNELS.include? channel_name
          client.conversations_invite(
            channel: SlackMessage::CHANNELS[channel_name][:channel_id],
            users: user_id
          )
        else
          post_ephemeral(
            channel_id: channel_id,
            user_id: user_id,
            channel_name: current_channel_name,
            client: client,
            message: "I could not find that channel. Please check the name against \"help\"."
          )
        end
      rescue Slack::Web::Api::Errors::ChannelNotFound
        post_ephemeral(
          channel_id: channel_id,
          user_id: user_id,
          channel_name: current_channel_name,
          client: client,
          message: "I could not find that channel. Please check the name against \"help\" or contact Jennifer with channel name: #{channel_name}."
        )
      rescue Slack::Web::Api::Errors::AlreadyInChannel
        post_ephemeral(
          channel_id: channel_id,
          user_id: user_id,
          channel_name: current_channel_name,
          client: client,
          message: "Slack seems to think you are already in that channel! Please check your existing channel list for ##{channel_name}."
        )
      rescue => e
        post_ephemeral(
          channel_id: channel_id,
          user_id: user_id,
          channel_name: current_channel_name,
          client: client,
          message: "There was an error! Please check #{channel_name} against list in help.
If it looks like a bug, please copy and send this message to Jennifer Konikowski:
#{e.message}"
        )
        raise
      end
    end

    def self.post_ephemeral(channel_id:, user_id:, channel_name:, client:, message: nil, blocks: nil)
      if channel_name == "directmessage"
        create_conversation(group: [user_id], text: message, type: :dm, client: client) if message
        create_conversation(group: [user_id], message: blocks, type: :dm, client: client) if blocks
      elsif message
        client.chat_postEphemeral(
          channel: channel_id,
          user: user_id,
          text: message
        )
      else
        client.chat_postEphemeral(
          channel: channel_id,
          user: user_id,
          blocks: blocks
        )
      end
    end

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
    def self.create_conversation(group:, type:, text: nil, message: nil, client: nil)
      client ||= default_client
      conv = client.conversations_open(users: group.join(","))
      if text
        client.chat_postMessage(
          channel: conv.channel.id,
          text: text
        )
      else
        message = generate_message(group: group, type: type, message: message)
        client.chat_postMessage(
          channel: conv.channel.id,
          blocks: message
        )
      end
    end

    # Given a user id, channel, and message text, it posts a message to the mod channel.
    #
    # @param user_id [String] slack user id of user who sent the message
    # @param channel_id [String] slack channel id where the user initially typed /mods
    # @param channel_name [String] slack channel name where user initially reached out to /mods
    # @param text [String] message text from user to mods
    def self.send_mod_message(user_id:, channel_id:, channel_name:, text:, client: nil)
      client ||= default_client
      begin
        if text == "list"
          return list_mods(
            user_id: user_id,
            channel_id: channel_id,
            channel_name: channel_name,
            client: client
          )
        end
        client.chat_postMessage(
          channel: ENV["MOD_CHANNEL"],
          blocks: SlackMessage.mod_message(
            user_id: user_id,
            channel_id: channel_id,
            channel_name: channel_name,
            text: text
          )
        )
        post_ephemeral(
          channel_id: channel_id,
          user_id: user_id,
          channel_name: channel_name,
          client: client,
          message: "Your message has been sent to the mods. Want to see the current mods? Type `/mods list`."
        )
      rescue => e
        post_ephemeral(
          channel_id: channel_id,
          user_id: user_id,
          channel_name: channel_name,
          client: client,
          message: "There was an error! Please copy and send this message to Jennifer:
#{e.message}"
        )
        raise
      end
    end

    def self.list_mods(user_id:, channel_id:, channel_name:, client: nil)
      post_ephemeral(
        channel_id: channel_id,
        user_id: user_id,
        channel_name: channel_name,
        client: client,
        message: "The current mods are: #{current_mods(client: client).join(", ")}"
      )
    end

    def self.current_mods(client: nil)
      client ||= default_client
      mods = client.conversations_members(channel: ENV["MOD_CHANNEL"])
      mods.delete("U01URMWE2UB") # remove the bot
      mods.map { |u| client.users_info(user: u)["user"]["real_name"] }
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
        SlackMessage.group_message(group: group)
      else
        message
      end
    end

    def self.default_client
      ::Slack::Web::Client.new(token: ENV["SLACK_OAUTH_TOKEN"])
    end
  end
end

# Slack message templates built initially using the [Slack Block Kit Builder](https://api.slack.com/block-kit)
module SlackMessage
  module_function

  # Generates the pair message for a pair of users
  #
  # @param pair [Array of Arrays of Strings] pairs of users, ex: [["U1234", "U2345"], ["U3456", "U4567"]]
  # @return [JSON] message content fitting Slack's block kit requirements
  def pair_message(pair:)
    pair_usernames = pair.map { |user| "<@#{user}>" }.to_sentence
    [
      {
        type: "section",
        block_id: "pair_introduction",
        text: {
          type: "mrkdwn",
          text: ":wave: Hi #{pair_usernames}! You've both been paired up for a coffee chat from <##{ENV["PAIRING_CHANNEL"]}>! Find a time to meet (Calendly is great for this) and have fun!"
        }
      }
    ]
  end

  # Generates the group message for a group of users
  #
  # @param group [Array of Arrays of Strings] groups of users, ex: [["U1234", "U2345", "U3456", "U4567"]]
  # @return [JSON] message content fitting Slack's block kit requirements
  def group_message(group:)
    group_usernames = group.map { |user| "<@#{user}>" }.to_sentence
    [
      {
        type: "section",
        block_id: "group_introduction",
        text: {
          type: "mrkdwn",
          text: ":wave: Hi #{group_usernames}! You've both been grouped up for a coffee chat from <##{ENV["GROUPS_CHANNEL"]}>! Find a time to meet and have fun!"
        }
      }
    ]
  end

  # Generates a message to the mod channel
  #
  # @param user_id [String] slack user id of user sending message to mods
  # @param channel_id [String] slack channel id user is sending message from
  # @param text [String] text of message
  # @return [JSON] message content fitting Slack's block kit requirements
  def mod_message(user_id:, channel_id:, text:)
    [
      {
        type: "section",
        block_id: "mod_message",
        text: {
          type: "mrkdwn",
          text: "Message from <@#{user_id}>
in <##{channel_id}>:
#{text}"
        }
      }
    ]
  end
end

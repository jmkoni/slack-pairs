# Slack message templates built initially using the [Slack Block Kit Builder](https://api.slack.com/block-kit)
module SlackMessage
  module_function

  CHANNELS = {
    bipoc: {channel_id: "C01SYB3QMNW", description: "for anyone who identifies as BIPOC"},
    cheersqueers: {channel_id: "C01T4KG9UUU", description: "LGBTQA+"},
    latinidad: {channel_id: "C01SJ0F510F", description: "for Latinx APers"},
    aapi: {channel_id: "C01TNFWDA9W", description: "for Asian and Pacific Islander APers"},
    south_asian: {channel_id: "C01SXKU357Y", description: "for South Asian APers"},
    accountabilibuddies: {channel_id: "C021TR2N5FZ", description: "for fitness/weight loss accountability"},
    dungeons_and_dragons: {channel_id: "C0257UWRF8A", description: "if you want to play D&D"},
    wakanda: {channel_id: "C01SYCRDFCJ", description: "for Black APers"},
    bipolar_bpd_support: {channel_id: "C04RFB6NCG5", description: "safe space for talking about the highs and lows of mood management"},
    nonmonogamy: {channel_id: "", description: "safe space for discussing the ins and outs of nonmonogamy"},
    plus_size_party: {channel_id: "", description: "for plus-size APers"}
  }

  def help_message
    [
      {
        type: "section",
        block_id: "help_message",
        text: {
          type: "mrkdwn",
          text: "*bipoc:* #{CHANNELS[:bipoc][:description]}
*cheersqueers:* #{CHANNELS[:cheersqueers][:description]}
*latinidad:* #{CHANNELS[:latinidad][:description]}
*aapi:* #{CHANNELS[:aapi][:description]}
*south_asian:* #{CHANNELS[:south_asian][:description]}
*wakanda:* #{CHANNELS[:wakanda][:description]}
*accountabilibuddies:* #{CHANNELS[:accountabilibuddies][:description]}
*dungeons_and_dragons:* #{CHANNELS[:dungeons_and_dragons][:description]}
*bipolar_bpd_support:* #{CHANNELS[:bipolar_bpd_support][:description]}
*nonmonogamy:* #{CHANNELS[:nonmonogamy][:description]}
*plus_size_party:* #{CHANNELS[:plus_size_party][:description]}
"
        }
      }
    ]
  end

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

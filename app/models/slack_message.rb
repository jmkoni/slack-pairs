module SlackMessage
  module_function

  def pair_message(pair:)
    pair_usernames = pair.map { |user| "<@#{user}>" }.to_sentence
    [
      {
        type: "section",
        block_id: "pair_introduction",
        text: {
          type: "mrkdwn",
          text: ":wave: Hi#{pair_usernames}! #{ENV["PAIR_MESSAGE"]}"
        }
      }
    ]
  end

  def mod_message(user_id:, channel_id:, text:)
    [
      {
        type: "section",
        block_id: "mod_message",
        text: {
          type: "mrkdwn",
          text: "Message from <@#{user_id}>
#{message_prompt(channel_id: channel_id)}:
#{text}"
        }
      }
    ]
  end

  def message_prompt(channel_id:)
    if channel_id.first == "D"
      "in DM conversation with <##{channel_id}>"
    else
      "in <##{channel_id}>"
    end
  end
end

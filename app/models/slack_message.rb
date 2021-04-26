module SlackMessage
  module_function

  def pair_message(pair:)
    pair_usernames = ""
    pair_usernames = " <@#{pair[0]}> and <@#{pair[1]}>" if pair.size == 2
    pair_usernames = " <@#{pair[0]}>, <@#{pair[1]}>, and <@#{pair[2]}>" if pair.size == 3
    [
      {
        type: "section",
        block_id: "pair_introduction",
        text: {
          type: "mrkdwn",
          text: ":wave: Hi#{pair_usernames}! You've both been paired up for a coffee chat from #coffee-buddies! Find a time to meet (Calendly is great for this) and have fun!"
        }
      }
    ]
  end
end

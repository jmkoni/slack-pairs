module SlackMessage
  module_function

  def pair_message(pair:)
    [
      {
        type: "section",
        block_id: "pair_introduction",
        text: {
          type: "mrkdwn",
          text: ":wave: Hi <@#{pair[0]}> and <@#{pair[1]}>! You've both been paired up for a coffee chat from #coffee-buddies! Find a time to meet (Calendly is great for this) and have fun!"
        }
      }
    ]
  end
end

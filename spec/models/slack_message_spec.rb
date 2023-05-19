require "rails_helper"

RSpec.describe SlackMessage do
  it "generates pair message" do
    ENV["PAIRING_CHANNEL"] = "C123"
    message = SlackMessage.pair_message(pair: ["123", "456"])
    expected_message = [
      {
        type: "section",
        block_id: "pair_introduction",
        text: {
          type: "mrkdwn",
          text: ":wave: Hi <@123> and <@456>! You've both been paired up for a coffee chat from <#C123>! Find a time to meet (Calendly is great for this) and have fun!"
        }
      }
    ]

    expect(message).to eq expected_message
  end

  it "generates group message" do
    ENV["GROUPS_CHANNEL"] = "C123"
    message = SlackMessage.group_message(group: ["123", "456", "789"])
    expected_message = [
      {
        type: "section",
        block_id: "group_introduction",
        text: {
          type: "mrkdwn",
          text: ":wave: Hi <@123>, <@456>, and <@789>! You've both been grouped up for a coffee chat from <#C123>! Find a time to meet and have fun!"
        }
      }
    ]

    expect(message).to eq expected_message
  end

  it "generates mod message" do
    message = SlackMessage.mod_message(user_id: "U123", channel_id: "C123", channel_name: "fun_times", text: "something not great happened.")
    expected_message = [
      {
        type: "section",
        block_id: "mod_message",
        text: {
          type: "mrkdwn",
          text: "Message from <@U123>
in <#C123> (fun_times):
something not great happened."
        }
      }
    ]
    expect(message).to eq expected_message
  end
end

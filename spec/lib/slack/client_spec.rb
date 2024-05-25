require "rails_helper"

RSpec.describe Slack::Client do
  context "create conversations" do
    let(:client) { double(Slack::Web::Client) }

    it "creates a pairing conversation" do
      conversation = OpenStruct.new
      channel = OpenStruct.new
      channel.id = 2
      conversation.channel = channel
      expected_message = SlackMessage.pair_message(pair: ["123", "456"])
      allow(client).to receive(:conversations_open).with(users: "123,456").and_return(conversation)
      allow(client).to receive(:chat_postMessage).with(channel: 2, blocks: expected_message)
      Slack::Client.create_conversation(group: ["123", "456"], type: :pairing, client: client)
    end

    it "creates a group conversation" do
      conversation = OpenStruct.new
      channel = OpenStruct.new
      channel.id = 2
      conversation.channel = channel
      expected_message = SlackMessage.group_message(group: ["123", "456", "789"])
      allow(client).to receive(:conversations_open).with(users: "123,456,789").and_return(conversation)
      allow(client).to receive(:chat_postMessage).with(channel: 2, blocks: expected_message)
      Slack::Client.create_conversation(group: ["123", "456", "789"], type: :groups, client: client)
    end
  end

  context "sends a mod message" do
    let(:client) { double(Slack::Web::Client) }

    it "works with no error" do
      ENV["MOD_CHANNEL"] = "678"
      message = SlackMessage.mod_message(user_id: "123", channel_id: "345", channel_name: "test", text: "something is awry")
      expect(client).to receive(:chat_postMessage).with(channel: "678", blocks: message)
      expect(client).to receive(:chat_postEphemeral).with(channel: "345", text: "Your message has been sent to the mods.", user: "123")
      Slack::Client.send_mod_message(user_id: "123", channel_id: "345", channel_name: "test", text: "something is awry", client: client)
    end

    it "works with no error in DM" do
      ENV["MOD_CHANNEL"] = "678"
      conversation = OpenStruct.new
      channel = OpenStruct.new
      channel.id = 2
      conversation.channel = channel
      message = SlackMessage.mod_message(user_id: "123", channel_id: "345", channel_name: "directmessage", text: "something is awry")
      expect(client).to receive(:chat_postMessage).with(channel: "678", blocks: message)
      allow(client).to receive(:conversations_open).with(users: "123").and_return(conversation)
      expect(client).to receive(:chat_postMessage).with(channel: 2, text: "Your message has been sent to the mods.")
      Slack::Client.send_mod_message(user_id: "123", channel_id: "345", channel_name: "directmessage", text: "something is awry", client: client)
    end

    it "will error" do
      ENV["MOD_CHANNEL"] = "678"
      error = StandardError.new("test")
      message = SlackMessage.mod_message(user_id: "123", channel_id: "345", channel_name: "test", text: "something is awry")
      allow(client).to receive(:chat_postMessage).with(channel: "678", blocks: message).and_raise(error)
      expect(client).to receive(:chat_postEphemeral).with(channel: "345", text: "There was an error! Please copy and send this message to Jennifer:\ntest", user: "123")
      expect { Slack::Client.send_mod_message(user_id: "123", channel_id: "345", channel_name: "test", text: "something is awry", client: client) }.to raise_error(error)
    end
  end

  context "add_user_to_channel" do
    let(:client) { double(Slack::Web::Client) }

    it "sends help message" do
      expect(client).to receive(:chat_postEphemeral).with({channel: "6890", user: "1235", blocks: SlackMessage.help_message})
      Slack::Client.add_user_to_channel(
        user_id: "1235",
        channel_id: "6890",
        current_channel_name: "general",
        channel_name: "HELP",
        client: client
      )
    end

    it "sends help message via direct message" do
      conversation = OpenStruct.new
      channel = OpenStruct.new
      channel.id = 2
      conversation.channel = channel
      allow(client).to receive(:conversations_open).with(users: "1235").and_return(conversation)
      expect(client).to receive(:chat_postMessage).with({channel: 2, blocks: SlackMessage.help_message})
      Slack::Client.add_user_to_channel(
        user_id: "1235",
        channel_id: "2",
        current_channel_name: "directmessage",
        channel_name: "HELP",
        client: client
      )
    end

    it "sends message if channel not in list direct message" do
      conversation = OpenStruct.new
      channel = OpenStruct.new
      channel.id = 2
      conversation.channel = channel
      message = "I could not find that channel. Please check the name against \"help\"."
      allow(client).to receive(:conversations_invite).with(channel: "C01SYB3QMNW", users: "1235").and_return(Slack::Web::Api::Errors::ChannelNotFound)
      allow(client).to receive(:conversations_open).with(users: "1235").and_return(conversation)
      expect(client).to receive(:chat_postMessage).with({channel: 2, text: message})
      Slack::Client.add_user_to_channel(
        user_id: "1235",
        channel_id: "2",
        current_channel_name: "directmessage",
        channel_name: "test",
        client: client
      )
    end

    it "sends error message if cannot find channel" do
      expect(client).to receive(:chat_postEphemeral).with({channel: "6890", user: "1235", text: "I could not find that channel. Please check the name against \"help\"."})
      Slack::Client.add_user_to_channel(
        user_id: "1235",
        channel_id: "6890",
        current_channel_name: "general",
        channel_name: "lolnope",
        client: client
      )
    end

    it "adds user to channel" do
      expect(client).to receive(:conversations_invite).with({channel: "C01SYB3QMNW", users: "1235"})
      Slack::Client.add_user_to_channel(
        user_id: "1235",
        channel_id: "6890",
        current_channel_name: "general",
        channel_name: "BiPoc",
        client: client
      )
    end

    it "cannot find the channel" do
      expect(client).to receive(:conversations_invite).with({channel: "C01SYB3QMNW", users: "1235"}).and_raise(Slack::Web::Api::Errors::ChannelNotFound.new("bipoc"))
      expect(client).to receive(:chat_postEphemeral).with({channel: "6890", user: "1235", text: "I could not find that channel. Please check the name against \"help\" or contact Jennifer with channel name: bipoc."})
      Slack::Client.add_user_to_channel(
        user_id: "1235",
        channel_id: "6890",
        current_channel_name: "general",
        channel_name: "BiPoc",
        client: client
      )
    end

    it "errors if the user is already in the channel" do
      expect(client).to receive(:conversations_invite).with({channel: "C01SYB3QMNW", users: "1235"}).and_raise(Slack::Web::Api::Errors::AlreadyInChannel.new("bipoc"))
      expect(client).to receive(:chat_postEphemeral).with({channel: "6890", user: "1235", text: "Slack seems to think you are already in that channel! Please check your existing channel list for #bipoc."})
      Slack::Client.add_user_to_channel(
        user_id: "1235",
        channel_id: "6890",
        current_channel_name: "general",
        channel_name: "BiPoc",
        client: client
      )
    end

    it "lets the user know if there is a random error" do
      expect(client).to receive(:conversations_invite).with({channel: "C01SYB3QMNW", users: "1235"}).and_raise(Slack::Web::Api::Errors::ChannelCannotBeUnshared.new("oh no"))
      expect(client).to receive(:chat_postEphemeral).with({channel: "6890", user: "1235", text: "There was an error! Please check bipoc against list in help.\nIf it looks like a bug, please copy and send this message to Jennifer Konikowski:\noh no"})
      expect {
        Slack::Client.add_user_to_channel(
          user_id: "1235",
          channel_id: "6890",
          current_channel_name: "general",
          channel_name: "BiPoc",
          client: client
        )
      }.to raise_error(Slack::Web::Api::Errors::ChannelCannotBeUnshared)
    end
  end
end

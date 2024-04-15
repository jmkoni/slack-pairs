require 'rails_helper'

RSpec.describe Slack::Client do
  before do
  end

  context "add_user_to_channel" do
    before { @mock_client = double }

    it 'sends help message' do
      expect(@mock_client).to receive(:chat_postEphemeral).with({channel: '6890', user: '1235', blocks: SlackMessage.help_message})
      Slack::Client.add_user_to_channel(
        user_id: '1235',
        channel_id: '6890',
        current_channel_name: 'general',
        channel_name: 'HELP',
        client: @mock_client
      )
    end

    it 'sends error message if cannot find channel' do
      expect(@mock_client).to receive(:chat_postEphemeral).with({channel: '6890', user: '1235', text: "I could not find that channel. Please check the name against \"help\"."})
      Slack::Client.add_user_to_channel(
        user_id: '1235',
        channel_id: '6890',
        current_channel_name: 'general',
        channel_name: 'lolnope',
        client: @mock_client
      )
    end

    it 'adds user to channel' do
      expect(@mock_client).to receive(:conversations_invite).with({channel: 'C01SYB3QMNW', users: '1235'})
      Slack::Client.add_user_to_channel(
        user_id: '1235',
        channel_id: '6890',
        current_channel_name: 'general',
        channel_name: 'BiPoc',
        client: @mock_client
      )
    end

    it 'cannot find the channel' do
      expect(@mock_client).to receive(:conversations_invite).with({channel: 'C01SYB3QMNW', users: '1235'}).and_raise(Slack::Web::Api::Errors::ChannelNotFound.new('bipoc'))
      expect(@mock_client).to receive(:chat_postEphemeral).with({channel: '6890', user: '1235', text: "I could not find that channel. Please check the name against \"help\" or contact Jennifer with channel name: bipoc."})
      Slack::Client.add_user_to_channel(
        user_id: '1235',
        channel_id: '6890',
        current_channel_name: 'general',
        channel_name: 'BiPoc',
        client: @mock_client
      )
    end

    it 'errors if the user is already in the channel' do
      expect(@mock_client).to receive(:conversations_invite).with({channel: 'C01SYB3QMNW', users: '1235'}).and_raise(Slack::Web::Api::Errors::AlreadyInChannel.new('bipoc'))
      expect(@mock_client).to receive(:chat_postEphemeral).with({channel: '6890', user: '1235', text: "Slack seems to think you are already in that channel! Please check your existing channel list for #bipoc."})
      Slack::Client.add_user_to_channel(
        user_id: '1235',
        channel_id: '6890',
        current_channel_name: 'general',
        channel_name: 'BiPoc',
        client: @mock_client
      )
    end

    it 'lets the user know if there is a random error' do
      expect(@mock_client).to receive(:conversations_invite).with({channel: 'C01SYB3QMNW', users: '1235'}).and_raise(Slack::Web::Api::Errors::ChannelCannotBeUnshared.new('oh no'))
      expect(@mock_client).to receive(:chat_postEphemeral).with({channel: '6890', user: '1235', text: "There was an error! Please check bipoc against list in help.\nIf it looks like a bug, please copy and send this message to Jennifer Konikowski:\noh no"})
      expect { Slack::Client.add_user_to_channel(
        user_id: '1235',
        channel_id: '6890',
        current_channel_name: 'general',
        channel_name: 'BiPoc',
        client: @mock_client
      ) }.to raise_error(Slack::Web::Api::Errors::ChannelCannotBeUnshared)
    end
  end
end

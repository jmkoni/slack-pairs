class CreatePairsJob < ApplicationJob
  def self.perform
    Rails.logger.info("Running CreatePairsJob")
    date = Date.today
    if date.monday? && date.cweek.odd?
      Rails.logger.info("It's a Monday on an odd week! Generating pairs!")
      members = Slack::Client.get_channel_users
      pairs = pair_members(members: members)
      start_conversations(pairs: pairs)
      Rails.logger.info("Started conversations with #{pairs.count} pairs")
    end
  end

  def self.pair_members(members:)
    pairs = []
    members.shuffle!
    pairs << members.shift(4) while members.any?
    pairs[-2] << pairs.last.pop if pairs.last.length == 1
  end

  def self.start_conversations(pairs:)
    pairs.each { |pair| Slack::Client.create_conversation(pair: pair) }
  end
end

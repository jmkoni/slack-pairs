class CreatePairsJob < ApplicationJob
  def self.perform
    date = Date.today
    if date.monday? && date.cweek.odd?
      Rails.logger.info("Running CreatePairsJob")
      members = Slack::Client.get_channel_users
      pairs = pair_members(members: members)
      start_conversations(pairs: pairs)
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

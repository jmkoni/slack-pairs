class CreatePairsJob < ApplicationJob
  def self.perform
    Rails.logger.info("Running CreatePairsJob")
    members = Slack::Client.get_channel_users
    pairs = pair_members(members: members)
    start_conversations(pairs: pairs)
  end

  def self.pair_members(members:)
    pairs = []
    while members.size > 3
      temp_pair = members.sample(2)
      pairs << temp_pair
      temp_pair.each { |pair| members.delete(pair) }
    end
    pairs << members.to_a
    pairs
  end

  def self.start_conversations(pairs:)
    # pairs.each do |pair|
    Slack::Client.create_conversation(pair: ["U01TN43PUP2"], total_pairs: pairs.count)
    # end
  end
end

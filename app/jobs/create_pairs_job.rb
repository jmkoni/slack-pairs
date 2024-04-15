class CreatePairsJob < ApplicationJob
  MIN_GROUP_SIZE = 2

  class << self
    def perform
      Rails.logger.info("Running CreatePairsJob")
      date = Date.today
      if date.monday?
        if (ENV["MONTHLY"] && date.mday <= 7) || (!ENV["MONTHLY"] && date.cweek.odd?)
          Rails.logger.info("It's a Monday on the right week! Generating pairs!")
          perform!
        end
      end
    end

    def perform!
      members = Slack::Client.get_channel_users
      pairs = pair_members(members: members)
      start_conversations(pairs: pairs)
      Rails.logger.info("Started conversations with #{pairs.count} pairs")
    end

    def pair_members(members:)
      pairs = []
      members.shuffle!
      pairs << members.shift(MIN_GROUP_SIZE) while members.any?
      balance_pairs(pairs)
    end

    def balance_pairs(pairs)
      if pairs.last.length == 1
        pairs[-2] << pairs.last.pop
        pairs.pop
      end
      pairs
    end

    def start_conversations(pairs:)
      pairs.each { |pair| Slack::Client.create_conversation(pair: pair) }
    end
  end
end

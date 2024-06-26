# Generates groups for both a groups and pairing channel
class CreateGroupsJob < ApplicationJob
  MIN_GROUP_SIZE = 2 # allows for a group of 3
  MAX_GROUP_SIZE = 4 # allows for a group of 3

  class << self
    # Creates chats if the channels exist as environment variables
    def perform
      Rails.logger.info("Running CreateGroupsJob")
      
      create_pairs if ENV["PAIRING_CHANNEL"].present?
          Rails.logger.info("It's the first Monday of the month! Generating pairs!")
          create_pairs
        end
      create_groups if ENV["GROUPS_CHANNEL"].present?
          Rails.logger.info("It's a Monday on the right week! Generating groups!")
          create_groups
        end
      
    end

    # Gets the users from the pairing channel (stored as an environment variable), groups,
    # balances groups (so there isn't a group of 1), and starts the conversations
    def create_pairs
      members = Slack::Client.get_channel_users(channel_id: ENV["PAIRING_CHANNEL"])
      return if members.length < MIN_GROUP_SIZE
      pairs = group_members(members: members, group_size: MIN_GROUP_SIZE)
      pairs = balance_pairs(pairs)
      start_conversations(groups: pairs, type: :pairing)
      Rails.logger.info("Started conversations with #{pairs.count} pairs")
    end

    # Gets the users from the groups channel (stored as an environment variable), groups,
    # balances groups (so there isn't a group of less than 3), and starts the conversations
    def create_groups
      members = Slack::Client.get_channel_users(channel_id: ENV["GROUPS_CHANNEL"])
      return if members.length < MIN_GROUP_SIZE
      groups = group_members(members: members, group_size: MAX_GROUP_SIZE)
      groups = balance_groups(groups)
      start_conversations(groups: groups, type: :groups)
      Rails.logger.info("Started conversations with #{groups.count} groups")
    end

    # Randomizes the list of members, shifts (take the top) X members (where X is group_size), and returns the array
    #
    # @param members [Array of Strings] list of channel members, ex: ["U1234", "U2345", "U3456"]
    # @param group_size [Integer] in this context, maximum size of the group. Currently 2 or 4.
    # @return [Array of Array of Strings] groups of channel members, ex: [["U1234", "U2345"], ["U3456"]]
    def group_members(members:, group_size:)
      groups = []
      members.shuffle!
      groups << members.shift(group_size) while members.any?
      groups
    end

    # Balances the pair arrays to ensure that everyone get a group (no groups of 1)
    #
    # @param pairs [Array of Array of Strings] current groups of channel members, ex: [["U1234", "U2345"], ["U3456"]]
    # @return [Array of Array of Strings] balanced group of channel members, ex: [["U1234", "U2345", "U3456"]]
    def balance_pairs(pairs)
      if pairs.last.length == 1 # [[1,2][3]]
        pairs[-2] << pairs.last.pop # [[1,2,3][]]
        pairs.pop # [[1,2,3]]
      end
      pairs
    end

    # Balances the group arrays to ensure that there are no groups smaller than 3
    #
    # @param groups [Array of Array of Strings] current groups of channel members, ex: [["U1234", "U2345", "U3456", "U4567"], ["U5678", "U6789"]]
    # @return [Array of Array of Strings] balanced group of channel members, ex: [["U1234", "U2345", "U3456"], ["U4567", "U5678", "U6789"]]
    def balance_groups(groups)
      return groups if groups.length < 2

      i = -2
      while groups.last.length < (MAX_GROUP_SIZE - 1)
        groups.last << groups[i].pop
        i -= 1
      end
      groups
    end

    # Starts up the conversations for each group
    #
    # @param groups [Array of Array of Strings] balanced groups of channel users
    # @param type [Symbol] group type so we send the right message. Currently either :pairing or :groups
    def start_conversations(groups:, type:)
      groups.each do |group|
        Slack::Client.create_conversation(group: group, type: type)
      end
    end
  end
end

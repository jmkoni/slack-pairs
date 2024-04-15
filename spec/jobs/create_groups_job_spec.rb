require "rails_helper"

RSpec.describe CreateGroupsJob do
  it "pairs people on first monday if pairing channel is set" do
    ENV["PAIRING_CHANNEL"] = "ABCD"
    allow(Date).to receive(:today).and_return(Date.new(2021, 6, 7))
    allow(Slack::Client).to receive(:get_channel_users).and_return((1..21).to_a)
    expect(Slack::Client).to receive(:create_conversation).exactly(10)
    CreateGroupsJob.perform
  end

  it "doesn't group people on odd mondays if it's not the first monday" do
    ENV["PAIRING_CHANNEL"] = "ABCD"
    allow(Date).to receive(:today).and_return(Date.new(2021, 6, 21))
    expect(Slack::Client).to receive(:get_channel_users).exactly(0)
    expect(Slack::Client).to receive(:create_conversation).exactly(0)
    CreateGroupsJob.perform
  end

  it "groups people on first monday if groups channel is set" do
    ENV["GROUPS_CHANNEL"] = "ABCD"
    allow(Date).to receive(:today).and_return(Date.new(2021, 6, 14))
    allow(Slack::Client).to receive(:get_channel_users).and_return((1..21).to_a)
    expect(Slack::Client).to receive(:create_conversation).exactly(6)
    CreateGroupsJob.perform
  end

  it "groups members into appropriately sized groups" do
    members = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    groups = CreateGroupsJob.group_members(members: members, group_size: 2)
    expect(groups.size).to eq(6)
    expect(groups.last.size).to eq(1)
  end

  it "balances pairs" do
    groups = [[1, 2], [3, 4], [5, 6], [7]]
    groups = CreateGroupsJob.balance_pairs(groups)
    expect(groups.last).to eq([5, 6, 7])
  end

  it "balances groups" do
    groups = [[1, 2, 3, 4], [5, 6, 7, 8], [9]]
    groups = CreateGroupsJob.balance_groups(groups)
    expect(groups.last).to eq([9, 8, 4])
  end
end

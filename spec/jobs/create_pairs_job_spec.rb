require "rails_helper"

RSpec.describe CreatePairsJob do
  it "groups people" do
    allow(Date).to receive(:today).and_return(Date.new(2021, 6, 7))
    allow(Slack::Client).to receive(:get_channel_users).and_return((1..21).to_a)
    expect(Slack::Client).to receive(:create_conversation).exactly(10)
    CreatePairsJob.perform
  end
  it "only groups people on first monday if MONTHLY is set" do
    ENV["MONTHLY"] = "true"
    allow(Date).to receive(:today).and_return(Date.new(2021, 6, 7))
    allow(Slack::Client).to receive(:get_channel_users).and_return((1..21).to_a)
    expect(Slack::Client).to receive(:create_conversation).exactly(10)
    CreatePairsJob.perform
  end
  it "doesn't group people on odd mondays if MONTHLY is set" do
    ENV["MONTHLY"] = "true"
    allow(Date).to receive(:today).and_return(Date.new(2021, 6, 21))
    expect(Slack::Client).to receive(:get_channel_users).exactly(0)
    expect(Slack::Client).to receive(:create_conversation).exactly(0)
    CreatePairsJob.perform
  end
end

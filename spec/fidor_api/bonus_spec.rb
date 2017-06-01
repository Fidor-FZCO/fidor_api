require "spec_helper"

describe FidorApi::Bonus do
  let(:client) { FidorApi::Client.new(token: token) }
  let(:token)  { FidorApi::Token.new(access_token: "6d5c4491a0498630516269096e9a136e") }

  def expect_correct_bonus(bonus)
    expect(bonus).to be_instance_of(FidorApi::Bonus)
    expect(bonus.name).to eq("recommendation")
    expect(bonus.category).to eq("Bonusprogramm")
    expect(bonus.maximum_events_per_month).to eq(nil)
    expect(bonus.current_amount_per_event).to eq(20.0)
    expect(bonus.granted_events).to eq(0)
    expect(bonus.granted_amount).to eq(0)
    expect(bonus.pending_events).to eq(0)
    expect(bonus.pending_amount).to eq(0)
  end

  describe ".all" do
    it "returns all bonuses" do
      VCR.use_cassette("bonus/all", record: :once) do
        bonuses = client.bonuses
        expect(bonuses).to be_instance_of FidorApi::Collection
        expect_correct_bonus(bonuses.first)
      end
    end
  end
end

require "spec_helper"

describe FidorApi::Transfer::Pending do

  let(:client) { FidorApi::Client.new }

  describe ".find" do
    it "returns one record" do
      VCR.use_cassette("transfer/pending/find", record: :once) do
        transfer = client.pending_transfer "42af0f631dd47190680fb7d532be9af4"
        expect(transfer).to be_instance_of FidorApi::Transfer::Pending
        expect(transfer.id).to      eq "29c877af-1b2e-4a26-870a-3e9b7d38b742"
        expect(transfer.subject).to eq "Hello"
        expect(transfer.amount).to  eq BigDecimal.new("0.01")
        expect(transfer.state).to   eq "pending_beneficiary"
      end
    end
  end

end

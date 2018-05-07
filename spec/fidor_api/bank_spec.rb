require "spec_helper"

describe FidorApi::Bank do
  let(:client) { FidorApi::Client.new(token: token) }
  let(:token)  { FidorApi::Token.new(access_token: "f859032a6ca0a4abb2be0583b8347937") }

  describe ".find_by_iban" do
    it "returns an instance for valid ibans" do
      VCR.use_cassette("bank/find_by_iban/success", record: :once) do
        result = described_class.find_by_iban('DE27100777770209299700')
        expect(result).to be_instance_of described_class
        expect(result.bic).to  eq 'FDDODEMMXXX'
        expect(result.name).to eq 'FIDOR BANK AG'
      end
    end

    it "returns null for invalid ibans" do
      VCR.use_cassette("bank/find_by_iban/invalid", record: :once) do
        result = described_class.find_by_iban('DE000X000000000123')
        expect(result).to be_nil
      end
    end
  end
end

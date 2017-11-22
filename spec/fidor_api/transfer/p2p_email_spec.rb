require "spec_helper"

describe FidorApi::Transfer::P2pEmail do

  let(:client) { FidorApi::Client.new(token: token) }
  let(:token)  { FidorApi::Token.new(access_token: "0816d2665999fbd76a69c6f0050a49fa") }

  subject do
    described_class.new(
      account_id:              "29208706",
      external_uid:            "4279762F8",
      beneficiary_unique_name: "Johnny Doe",
      email:                   "johnny.doe@example.com",
      amount:                  BigDecimal.new("10.00"),
      currency:                "USD",
      subject:                 "Money for you",
      additional_attributes:   {"transfer_purpose" => "Computer services"}
    )
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :account_id          }
    it { is_expected.to validate_presence_of :external_uid        }
    it { is_expected.to validate_presence_of :email               }
    it { is_expected.to validate_presence_of :amount              }
    it { is_expected.to_not validate_presence_of :contact_name    }
  end

  describe "#as_json" do
    it "returns all writeable fields" do
      expect(subject.as_json).to eq(
        account_id: "29208706",
        amount: 1000,
        beneficiary: {
          unique_name: "Johnny Doe",
          contact: {},
          bank: {},
          routing_type: "FOS_P2P_EMAIL",
          routing_info: {
            email: "johnny.doe@example.com"
          }
        },
        currency: "USD",
        external_uid: "4279762F8",
        subject: "Money for you",
        additional_attributes: {"transfer_purpose" => "Computer services"},
        validation_mode: false
      )
    end
  end

end

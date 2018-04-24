require "spec_helper"

describe FidorApi::Transfer::Sepa do

  let(:client) { FidorApi::Client.new(token: token) }
  let(:token)  { FidorApi::Token.new(access_token: "0816d2665999fbd76a69c6f0050a49fa") }

  subject do
    described_class.new(
      account_id:              "29208706",
      external_uid:            "4279762F8",
      beneficiary_unique_name: "Johnny Doe",
      contact_name:            "John Doe",
      remote_iban:             "DE25700222000072855329",
      remote_bic:              "FDDODEMMXXX",
      amount:                  BigDecimal.new("10.00"),
      currency:                "EUR",
      subject:                 "Money for you"
    )
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :account_id   }
    it { is_expected.to validate_presence_of :amount       }
    it { is_expected.to validate_presence_of :contact_name }
    it { is_expected.to validate_presence_of :external_uid }
    it { is_expected.to validate_presence_of :remote_iban  }
  end

  describe "#save" do
    context "on success" do
      it "returns true and updates the attributes with received data" do
        VCR.use_cassette("transfer/sepa/save_success", record: :once) do
          expect(subject.save).to be true

          expect(subject.id).to be_nil
          expect(subject.needs_confirmation?).to be true

          action = subject.confirmable_action

          expect(action).to be_a FidorApi::ConfirmableAction
          expect(action.id).to eq "8437c0c7-f704-4fc8-8ee0-3c18aedc8484"
        end
      end
    end
  end

  describe "#as_json" do
    it "returns all writeable fields" do
      expect(subject.as_json).to eq(
        account_id: "29208706",
        amount: 1000,
        beneficiary: {
          unique_name: "Johnny Doe",
          contact: {
            name: "John Doe"
          },
          bank: {},
          routing_type: "SEPA",
          routing_info: {
            remote_iban: "DE25700222000072855329",
            remote_bic:  "FDDODEMMXXX"
          }
        },
        currency: "EUR",
        external_uid: "4279762F8",
        subject: "Money for you",
        validation_mode: false
      )
    end
  end

end

require "spec_helper"

describe FidorApi::Transfer::UaeDomestic do

  let(:client) { FidorApi::Client.new(token: token) }
  let(:token)  { FidorApi::Token.new(access_token: "0816d2665999fbd76a69c6f0050a49fa") }

  subject do
    client.build_uae_domestic_transfer(
      account_id:              "29208706",
      external_uid:            "4279762F8",
      beneficiary_unique_name: "Johnny Doe",
      contact_name:            "John Doe",
      contact_address_line_1:  "Street 123",
      bank_name:               "Bank Name",
      bank_address_line_1:     "Street 456",
      destination:             "external",
      account_type:            "account",
      account_number:          "AE070331234567890123456",
      swift_code:              "ARABAEADSHJ",
      amount:                  BigDecimal.new("10.00"),
      currency:                "AED",
      subject:                 "Money for you"
    )
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :account_id       }
    it { is_expected.to validate_presence_of :external_uid     }
    it { is_expected.to validate_presence_of :contact_name     }
    it { is_expected.to validate_presence_of :destination      }
    it { is_expected.to validate_presence_of :account_type     }
    it { is_expected.to validate_presence_of :account_number   }
    it { is_expected.to validate_presence_of :swift_code       }
    it { is_expected.to validate_presence_of :amount           }
    it { is_expected.to validate_presence_of :subject          }
  end

  describe "#save" do
    context "on success" do
      it "returns true and updates the attributes with received data" do
        VCR.use_cassette("transfer/uae_domestic/save_success", record: :once) do
          expect(subject.save).to be true

          expect(subject.id).to be_nil
          expect(subject.needs_confirmation?).to be true

          action = subject.confirmable_action

          expect(action).to be_a FidorApi::ConfirmableAction
          expect(action.id).to eq "8437c0c7-f704-4fc8-8ee0-3c18aedc8484"
        end
      end
    end

    context "on invalid object" do
      it "raises an error" do
        subject.account_id = nil

        expect { subject.save }.to raise_error FidorApi::InvalidRecordError
      end
    end

    context "on failure response" do
      it "returns false and provides errors" do
        subject.account_id = 999

        VCR.use_cassette("transfer/uae_domestic/save_failure", record: :once) do
          expect(subject.save).to be false
          expect(subject.errors[:account_id]).to eq ["should be the token user's account id"]
          expect(subject.errors[:account_number]).to eq ["is_invalid"]
          expect(subject.errors.details).to eq(
            account_id:     [{error: "should be the token user's account id"}],
            account_number: [{error: :invalid}]
          )
        end
      end
    end

    context "with a referenced pending transfer" do
      before do
        subject.pending_transfer_id = "42af0f631dd47190680fb7d532be9af4"
      end

      it "successfully saves the transfer" do
        VCR.use_cassette("transfer/uae_domestic/save_pending_transfer", record: :once) do
          expect(subject.save).to be true
        end
      end

      it "successfully saves the transfer" do
        expected_request_body = %q({"account_id":"29208706","external_uid":"4279762F8","amount":1000,"currency":"AED","subject":"Money for you","beneficiary":{"unique_name":"Johnny Doe","contact":{"name":"John Doe","address_line_1":"Street 123"},"bank":{"name":"Bank Name","address_line_1":"Street 456"},"routing_type":"UAE_DOMESTIC","routing_info":{"destination":"external","account_type":"account","account_number":"AE070331234567890123456","swift_code":"ARABAEADSHJ"}}})

        VCR.use_cassette("transfer/uae_domestic/save_pending_transfer", record: :once) do
          subject.save

          expect(WebMock).to have_requested(:post, "https://aps.fidor.de/pending_transfers/42af0f631dd47190680fb7d532be9af4/transfer")
            .with(body: expected_request_body).once
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
            name:           "John Doe",
            address_line_1: "Street 123"
          },
          bank: {
            name:           "Bank Name",
            address_line_1: "Street 456"
          },
          routing_type: "UAE_DOMESTIC",
          routing_info: {
            destination:    "external",
            account_type:   "account",
            account_number: "AE070331234567890123456",
            swift_code:     "ARABAEADSHJ"
          }
        },
        currency: "AED",
        external_uid: "4279762F8",
        subject: "Money for you"
      )
    end
  end

end

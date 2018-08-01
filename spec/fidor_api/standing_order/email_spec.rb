require "spec_helper"

describe FidorApi::StandingOrder::Email do

  let(:client) { FidorApi::Client.new(token: token) }
  let(:token)  { FidorApi::Token.new(access_token: "0816d2665999fbd76a69c6f0050a49fa") }

  subject do
    described_class.new(
      'account_id' =>            "29208706",
      'external_uid' =>            "4279762F8",
      'beneficiary_unique_name' => "Johnny Doe",
      'email' =>                   "peter@example.com",
      'amount' =>                  BigDecimal.new("10.00"),
      'currency' =>               "USD",
      'subject' =>                 "Money for you",
      'additional_attributes':   {"transfer_purpose" => "Computer services"},
      'schedule' => {
        'rhythm' => "weekly",
        'runtime_day_of_month' => 1,
        'runtime_day_of_week' => "Mon",
        'ultimate_run' => "2018-07-24"
      }
    )
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :account_id          }
    it { is_expected.to validate_presence_of :external_uid        }
    it { is_expected.to validate_presence_of :email               }
    it { is_expected.to validate_presence_of :amount              }
    it { is_expected.to_not validate_presence_of :contact_name    }
  end


  describe "#save" do
    context "on success" do
      it "returns true and updates the attributes with received data" do
        VCR.use_cassette("standing_order/email/save_success", record: :once) do
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
          contact: {},
          bank: {},
          routing_type: "FOS_P2P_EMAIL",
          routing_info: {
            email: "peter@example.com"
          }
        },
        currency: "USD",
        external_uid: "4279762F8",
        subject: "Money for you",
        additional_attributes: {"transfer_purpose" => "Computer services"},
        validation_mode: false,
        schedule: {
          rhythm: "weekly",
          runtime_day_of_month: "1",
          runtime_day_of_week: "Mon",
          ultimate_run: "2018-07-24",
          next_run: nil
        }
      )
    end
  end

end

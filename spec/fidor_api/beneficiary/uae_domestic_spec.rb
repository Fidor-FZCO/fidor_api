require "spec_helper"

describe FidorApi::Beneficiary::UaeDomestic do
  let(:token)  { FidorApi::Token.new(access_token: "73570bdde25a22bc7219acd1d43a1cde") }
  let(:client) { FidorApi::Client.new(token: token) }
  let(:beneficiary_id) { "9e6155e9-9b6f-464f-a14f-4db44e2ea1e2" }

  subject do
    client.build_uae_domestic_beneficiary(params)
  end

  context "when complete data is given" do
    let(:params) do
      {
        "account_id"       => "91318832",
        "unique_name"      => "jj_doey",
        "contact" => {
          "name"           => "John Doe",
          "address_line_1" => "Contact Address 1",
          "address_line_2" => "Contact Address 2",
          "city"           => "Contact City",
          "country"        => "Contact Country"
        }.compact,
        "bank" => {
          "name"           => "Bank Name",
          "address_line_1" => "Bank Address 1",
          "address_line_2" => "Bank Address 2",
          "city"           => "Bank City",
          "country"        => "Bank Country"
        }.compact,
        "routing_type"     => "UAE_DOMESTIC",
        "routing_info" => {
          "account_number" => "AE070331234567890123456",
          "swift_code"     => "ARABAEADSHJ"
        }.compact
      }.compact
    end

    describe "#save" do
      it "creates a beneficiary object and sets it's data" do
        VCR.use_cassette("beneficiary/save_success", record: :once) do
          expect(subject.save).to be_truthy

          expect(subject).to be_instance_of FidorApi::Beneficiary::UaeDomestic

          expect(subject.id).to                     eq beneficiary_id
          expect(subject.account_id).to             eq "91318832"
          expect(subject.contact_name).to           eq "John Doe"
          expect(subject.contact_address_line_1).to eq "Contact Address 1"
          expect(subject.contact_address_line_2).to eq "Contact Address 2"
          expect(subject.contact_city).to           eq "Contact City"
          expect(subject.contact_country).to        eq "Contact Country"
          expect(subject.bank_name).to              eq "Bank Name"
          expect(subject.bank_address_line_1).to    eq "Bank Address 1"
          expect(subject.bank_address_line_2).to    eq "Bank Address 2"
          expect(subject.bank_city).to              eq "Bank City"
          expect(subject.bank_country).to           eq "Bank Country"
          expect(subject.account_number).to         eq "AE070331234567890123456"
          expect(subject.swift_code).to             eq "ARABAEADSHJ"
        end
      end
    end
  end

  context "with missing data" do
    let(:params) do
      {"account_id" => ""}.compact
    end

    describe "#save" do
      it "returns error" do
        expect{subject.save}.to raise_error FidorApi::InvalidRecordError
      end
    end
  end
end

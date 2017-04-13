require "spec_helper"

module FidorApi
  describe CustomerConfirmations do
    let(:msisdn) { '491666666666' }
    let(:token) { '#MTAN#' }

    describe ".create_confirmation_token" do
      it "creates the confirmation token in banking" do
        VCR.use_cassette("customer_confirmations/create_success", record: :once) do
          returned_code = CustomerConfirmations.create_confirmation_token('mobile_phone', msisdn)
          expect(returned_code.status).to eq 201
        end
      end
    end

    describe '.confirm_resource' do
      it 'confirm the resource' do
        VCR.use_cassette("customer_confirmations/confirm_success", record: :once) do
          returned_code = CustomerConfirmations.confirm_resource('mobile_phone', msisdn, token)
          expect(returned_code.status).to eq 200
        end
      end
    end
  end
end

require "spec_helper"

describe FidorApi::Notification do

  describe "#notify" do
    let(:client) { FidorApi::Client.new(token: token) }
    let(:token)  { FidorApi::Token.new(access_token: "f859032a6ca0a4abb2be0583b8347937") }
    
    it "returns the notification" do
      VCR.use_cassette("notification/account_completed_sms", record: :once) do
        response = FidorApi::Notification.new.notify("account_completed_sms")

        expect(response).to be_instance_of FidorApi::Connectivity::Connection::Response
        expect(response.body["customer_id"]).to        eq "42"
        expect(response.body["type"]).to               eq "account_completed_sms"
      end
    end
  end
end

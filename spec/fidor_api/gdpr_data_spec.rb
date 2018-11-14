require "spec_helper"

describe FidorApi::GdprData do

  let(:client) { FidorApi::Client.new(token: token) }
  let(:token)  { FidorApi::Token.new(access_token: "635490b2e0946ea636b92ae839681380") }

  describe ".gdpr document" do
    it "returns one pdf attachment" do
      VCR.use_cassette("gdpr/attachment", record: :once) do
        response = described_class.attachment

        expect(response.status).to eq(200)
        expect(response.headers['Content-Transfer-Encoding']).to eq 'binary'
        expect(response.headers['content-type']).to include('application/pdf')
      end
    end
  end

end

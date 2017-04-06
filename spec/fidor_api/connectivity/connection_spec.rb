require "spec_helper"

module FidorApi
  describe Connectivity::Connection do
    let(:options) {
      {
        headers: {"FOO" => "bar"}
      }
    }

    it "allows passing in request headers" do
      stub_request(:post, "https://aps.fidor.de/transfers").to_return(status: 200, body: "{}")

      described_class.send(:request, "post", "/transfers", options)

      expect(WebMock).to have_requested(:post, "https://aps.fidor.de/transfers")
        .with(headers: {'Accept'=>'application/vnd.fidor.de; version=1,text/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer f859032a6ca0a4abb2be0583b8347937', 'Content-Length'=>'0', 'Content-Type'=>'application/json', 'Foo'=>'bar', 'User-Agent'=>'Ruby'})
    end
  end
end

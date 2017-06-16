require "spec_helper"

describe FidorApi::SddReturnTransaction do
  let(:sdd_return_create_url) { "https://aps.fidor.de/transactions/#{sdd_return_params[:transaction_id]}/debit_return" }
  let(:sdd_return_confirm_url) { "https://aps.fidor.de/transactions/#{sdd_return_params[:transaction_id]}/debit_return/confirm" }

  let(:sdd_return_params) do
    {
      transaction_id: '294834',
      reason: 'another return sdd reason'
    }
  end

  let(:subject) { described_class.new(sdd_return_params) }

  describe 'confirm' do
    it "should call banking" do
      stub_request(:put, sdd_return_confirm_url).to_return(status: 200, body: "", headers: {})
      subject.confirm
      expect(WebMock).to have_requested(:put, sdd_return_confirm_url)

    end
  end

  describe 'save' do
    before do
      FidorApi::Connectivity.access_token = 'f859032a6ca0a4abb2be0583b8347937'
    end

    it "should call banking" do
      stub_request(:post, sdd_return_create_url)
          .to_return(
              status: 201,
              body: "{}",
              headers: { "Content-Type" => "application/json" }
          )

      subject.save

      expect(WebMock).to have_requested(:post, sdd_return_create_url)
                             .with(body: { reason: sdd_return_params[:reason] })
    end
  end
end

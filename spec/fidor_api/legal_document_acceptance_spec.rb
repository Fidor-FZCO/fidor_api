require 'spec_helper'

describe FidorApi::LegalDocumentAcceptance do
  describe '.accept' do
    let(:client) { FidorApi::Client.new(token: token) }
    let(:token)  { FidorApi::Token.new(access_token: 'f859032a6ca0a4abb2be0583b8347937') }

    before do
      FidorApi::Connectivity.access_token = 'f859032a6ca0a4abb2be0583b8347937'
    end

    it 'creates legal document acceptance' do
      VCR.use_cassette('legal_document_acceptances/create') do
        response = client.accept_legal_document(document_type: 'general_terms_retail')
        expect(response.status).to eq 200
      end
    end
  end
end

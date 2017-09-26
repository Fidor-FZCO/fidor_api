require "spec_helper"

describe FidorApi::Connectivity::Connection::Response do
  context 'body' do
    let(:status){ 200 }
    context 'content type is JSON' do
      let(:headers){
        {
          'content-type' => 'application-json'
        }
      }
      it 'has a parsable raw body' do
        raw_body = '123'
        request = FidorApi::Connectivity::Connection::Response.new(status, headers, raw_body)
        expect(request.body).to eq 123
      end
      it 'raw body is empty string' do
        raw_body = ''
        request = FidorApi::Connectivity::Connection::Response.new(status, headers, raw_body)
        expect(request.body).to eq ''
      end
      it 'raw body is some string that causes error' do
        raw_body = 'foo-bar-fff'
        request = FidorApi::Connectivity::Connection::Response.new(status, headers, raw_body)
        expect{request.body}.to raise_error(JSON::ParserError).with_message(/foo-bar-fff/)
      end
    end
    context 'content type is other than JSON' do
      let(:headers){
        {
          'content-type' => 'text'
        }
      }
      it 'raw body' do
        raw_body = '123'
        request = FidorApi::Connectivity::Connection::Response.new(status, headers, raw_body)
        expect(request.body).to eq '123'
      end
    end
  end
end

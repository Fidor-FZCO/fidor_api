require "spec_helper"

module FidorApi
  class DummyResource < Connectivity::Resource
    extend ModelAttribute

    self.endpoint = Connectivity::Endpoint.new('/resource', :resource)

    attribute :id,   :string
    attribute :foo,  :string
    attribute :bar,  :string
  end

  describe Connectivity::Resource do
    let(:model) { DummyResource.new(id: 1001, foo: 'foo', bar: 'bar') }

    before do
      FidorApi::Connectivity.access_token = 'f859032a6ca0a4abb2be0583b8347937'
      WebMock.stub_request(:put, "https://aps.fidor.de/resource")
    end

    describe '#update_attributes' do
      it 'updates those attributes' do
        model.update_attributes(foo: 'foo2')
        expect(model.foo).to eq('foo2')
        expect(WebMock).to have_requested(:put, /\/resource$/)
          .with { |req| req.body == '{"foo":"foo2"}' }
          .once
      end
    end

    describe '#save failure with a 422 status' do
      before do
        WebMock.stub_request(:put, "https://aps.fidor.de/resource").to_return(
          body: '{"code":422,"errors":[{"field":"type","message":"code invalid"},{"field":"foo","message":"too short","key":"too_short","count":8},{"field":"bar","message":"something special","key":"something_special","options":{"answer":"42"}}],"message":"Not valid","key":["code_suspended"]}',
          status: 422
        )
      end

      it 'includes the key in the error keys' do
        model.save
        expect(model.error_keys.first).to eq('code_suspended')
        expect(model.errors.details).to eq({
          bar: [{ error: :something_special, answer: "42" }],
          foo: [{ error: :too_short, count: 8 }]
        })
      end
    end

    describe '#save failure with a 500 status' do
      before do
        WebMock.stub_request(:put, "https://aps.fidor.de/resource").to_return(body: 'Internal server error', status: 500)
      end

      it 'raises a ClientError' do
        expect do
          model.save
        end.to raise_error(FidorApi::ClientError, "Internal server error")
      end
    end

    describe '#save failure when there is no response (e.g. because connection failed)' do
      before do
        # abuse FidorApi::Connectivity to inject an early error
        expect(FidorApi::Connectivity).to receive(:access_token).and_raise(Faraday::ClientError.new("Failed to open TCP connection"))
      end

      it 'raises a ClientError' do
        expect do
          model.save
        end.to raise_error(FidorApi::ClientError)
      end
    end

    describe '#use default header in request' do
      before do
        FidorApi.configuration.default_headers_callback = Proc.new do
          { a: "b" }
        end
      end

      after do
        FidorApi.configuration.default_headers_callback = nil
      end

      it 'incorporates default headers in requests' do
        model.update_attributes(foo: 'foo2')
        expect(WebMock).to have_requested(:put, /\/resource$/)
          .with { |req| req.headers['A'] == 'b' }.once
      end
    end
  end
end

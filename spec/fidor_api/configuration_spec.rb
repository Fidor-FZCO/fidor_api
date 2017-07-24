require 'spec_helper'

describe FidorApi::Configuration do
  %w[callback_url oauth_url api_url].each do |param_name|
    describe "set #{param_name}" do
      it 'accepts good urls' do
        good_url = 'http://example.com:3000'
        subject.send("#{param_name}=", good_url)

        expect(subject.send(param_name)).to eq good_url
      end

      it 'raises an error on bad url' do
        bad_urls = %w[bad:/ur.l http://:5984/ http://]

        bad_urls.each do |bad_url|
          expect { subject.send("#{param_name}=", bad_url) }.to raise_error(FidorApi::ConfigurationError)
        end
      end

      it 'raises an error on blank url' do
        expect { subject.send("#{param_name}=", '') }.to raise_error(FidorApi::ConfigurationError)
      end

      it 'passes on nil' do
        expect { subject.send("#{param_name}=", nil) }.to_not raise_error
        expect(subject.send(param_name)).to be_nil
      end
    end
  end
end

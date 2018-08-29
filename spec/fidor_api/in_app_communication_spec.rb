require 'spec_helper'

describe FidorApi::InAppCommunication do
  let(:client) { FidorApi::Client.new(token: token) }
  let(:token)  { FidorApi::Token.new(access_token: 'f859032a6ca0a4abb2be0583b8347937') }

  def expect_correct_in_app_communication(in_app_communication)
    expect(in_app_communication).to be_instance_of FidorApi::InAppCommunication

    expect(in_app_communication.id).to                   eq(28170)
    expect(in_app_communication.active).to               eq(true)
    expect(in_app_communication.title).to                eq('title')
    expect(in_app_communication.body).to                 eq('body')
    expect(in_app_communication.description).to          eq('description')
    expect(in_app_communication.link_url).to             eq('https://external_link')
    expect(in_app_communication.link_external).to        eq(true)
    expect(in_app_communication.background_image_url).to eq('https://background_image_url')
    expect(in_app_communication.platform).to             eq('all')
    expect(in_app_communication.expiration_date).to      eq Time.new(2015, 8, 26, 15, 43, 30, "+00:00")
    expect(in_app_communication.created_at).to           eq Time.new(2015, 8, 26, 15, 43, 30, "+00:00")
    expect(in_app_communication.updated_at).to           eq Time.new(2015, 8, 26, 15, 43, 30, "+00:00")
  end

  describe ".all" do
    it "returns all in_app_communication records" do
      VCR.use_cassette("in_app_communication/all", record: :once) do
        in_app_communications = client.in_app_communications
        expect(in_app_communications).to be_instance_of FidorApi::Collection
        expect_correct_in_app_communication(in_app_communications.first)
      end
    end
  end
end

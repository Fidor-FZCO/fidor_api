require "simplecov"

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "fidor_api"
require "vcr"
require "byebug"
require "shoulda-matchers"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :faraday
end

FidorApi.configure do |config|
  config.callback_url    = "http://localhost:3000/auth/callback"
  config.oauth_url       = "http://localhost:5000"
  config.api_url         = "http://localhost:8080"
  config.client_id       = "84dd69b799bc1f0b"
  config.client_secret   = "735977c7e8a4f7410df55acd1b3b4205"
  config.htauth_user     = "fidor-mobile"
  config.htauth_password = "mobile!wir!bank$"
  config.affiliate_uid   = "1398b666-6666-6666-6666-666666666666"
  config.logging         = false
end

require 'uri'

module FidorApi
  class Configuration
    SCHEMES = %w(http https)

    attr_accessor \
      :affiliate_uid,
      :api_path,
      :client_id,
      :client_secret,
      :default_headers_callback,
      :htauth_password,
      :htauth_user,
      :logger,
      :logging,
      :os_type,
      :verify_ssl

    attr_reader :anonymous_auth, :api_url, :callback_url, :oauth_url

    def anonymous_auth=(value)
      allowed = [:htauth, :oauth_client]
      raise "Invalid value for `anonymous_auth` option. Must be one of #{allowed.inspect}" unless value.in? allowed
      @anonymous_auth = value
    end

    def callback_url=(url)
      check_url_validity(url)
      @callback_url = url
    end

    def oauth_url=(url)
      check_url_validity(url)
      @oauth_url = url
    end

    def api_url=(url)
      check_url_validity(url)
      @api_url = url
    end

    private

    def check_url_validity(url)
      return unless url
      raise(FidorApi::ConfigurationError, "URL #{url} is invalid") unless valid_url?(url)
    end

    def valid_url?(url)
      uri = URI.parse(url)
      return false unless SCHEMES.include?(uri.scheme)

      !uri.host.nil?
    rescue URI::InvalidURIError
      false
    end
  end
end

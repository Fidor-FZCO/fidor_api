require 'uri'

module FidorApi
  class Configuration
    SCHEMES = %w(http https)

    attr_accessor :api_path, :client_id, :client_secret, :htauth_user, :htauth_password, :os_type,
                  :affiliate_uid, :logging, :logger, :verify_ssl, :default_headers_callback
    attr_reader :callback_url, :oauth_url, :api_url

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

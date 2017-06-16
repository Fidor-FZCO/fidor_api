require "faraday"
require "active_support"
require "active_support/core_ext"
require "active_model"
require "model_attribute"
require "json"

module FidorApi
  extend self

  attr_accessor :configuration

  autoload :Account,               'fidor_api/account'
  autoload :AmountAttributes,      'fidor_api/amount_attributes'
  autoload :ApprovalRequired,      'fidor_api/approval_required'
  autoload :Auth,                  'fidor_api/auth'
  autoload :Beneficiary,           'fidor_api/beneficiary'
  autoload :Bonus,                 'fidor_api/bonus'
  autoload :Card,                  'fidor_api/card'
  autoload :CardLimitAttribute,    'fidor_api/card_limit_attribute'
  autoload :CardLimits,            'fidor_api/card_limits'
  autoload :Client,                'fidor_api/client'
  autoload :Collection,            'fidor_api/collection'
  autoload :ConfirmableAction,     'fidor_api/confirmable_action'
  autoload :CustomerConfirmations, 'fidor_api/customer_confirmations'
  autoload :Connectivity,          'fidor_api/connectivity'
  autoload :Customer,              'fidor_api/customer'
  autoload :Customers,             'fidor_api/customers/confirmations'
  autoload :Message,               'fidor_api/message'
  autoload :NotificationOptions,   'fidor_api/notification_options'
  autoload :Msisdn,                'fidor_api/msisdn'
  autoload :Password,              'fidor_api/password'
  autoload :Preauth,               'fidor_api/preauth'
  autoload :PreauthDetails,        'fidor_api/preauth_details'
  autoload :SessionToken,          'fidor_api/session_token'
  autoload :Token,                 'fidor_api/token'
  autoload :SddReturnTransaction,  'fidor_api/sdd_return_transaction'
  autoload :TransactionDetails,    'fidor_api/transaction_details'
  autoload :Transaction,           'fidor_api/transaction'
  autoload :Transfer,              'fidor_api/transfer'
  autoload :User,                  'fidor_api/user'
  autoload :Version,               'fidor_api/version'
  autoload :Notification,          'fidor_api/notification'

  class Configuration
    attr_accessor \
      :affiliate_uid,
      :anonymous_auth,
      :api_path,
      :api_url,
      :callback_url,
      :client_id,
      :client_secret,
      :default_headers_callback,
      :htauth_password,
      :htauth_user,
      :logger,
      :logging,
      :oauth_url,
      :os_type,
      :verify_ssl

    def anonymous_auth=(value)
      allowed = [:htauth, :oauth_client]
      raise "Invalid value for `anonymous_auth` option. Must be one of #{allowed.inspect}" unless value.in? allowed
      @anonymous_auth = value
    end
  end

  def configure
    self.configuration = Configuration.new.tap do |config|
      config.logging         = true
      config.logger          = Logger.new(STDOUT)
      config.os_type         = "iOS"
      config.verify_ssl      = true
      config.anonymous_auth  = :htauth
    end

    yield configuration

    begin
      require "faraday/detailed_logger"
    rescue LoadError
      configuration.logger.debug "NOTE: Install `faraday-detailed_logger` gem to get detailed log-output for debugging."
    end
  end

  def default_headers
    (FidorApi.configuration.default_headers_callback && FidorApi.configuration.default_headers_callback.call) || {}
  end
end

require "fidor_api/errors"
require "fidor_api/constants"

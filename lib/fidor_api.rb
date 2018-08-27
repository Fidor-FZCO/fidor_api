require "faraday"
require "active_support"
require "active_support/core_ext"
require "active_model"
require "model_attribute"
require "json"

module FidorApi
  extend self

  attr_accessor :configuration

  autoload :Account,                 'fidor_api/account'
  autoload :Address,                 'fidor_api/address'
  autoload :AmountAttributes,        'fidor_api/amount_attributes'
  autoload :ApprovalRequired,        'fidor_api/approval_required'
  autoload :Auth,                    'fidor_api/auth'
  autoload :Bank,                    'fidor_api/bank'
  autoload :Beneficiary,             'fidor_api/beneficiary'
  autoload :Bonus,                   'fidor_api/bonus'
  autoload :Card,                    'fidor_api/card'
  autoload :CardLimitAttribute,      'fidor_api/card_limit_attribute'
  autoload :CardLimits,              'fidor_api/card_limits'
  autoload :Client,                  'fidor_api/client'
  autoload :Collection,              'fidor_api/collection'
  autoload :Configuration,           'fidor_api/configuration'
  autoload :ConfirmableAction,       'fidor_api/confirmable_action'
  autoload :CustomerConfirmations,   'fidor_api/customer_confirmations'
  autoload :Connectivity,            'fidor_api/connectivity'
  autoload :Customer,                'fidor_api/customer'
  autoload :Customers,               'fidor_api/customers/confirmations'
  autoload :InAppCommunication,      'fidor_api/in_app_communication'
  autoload :Message,                 'fidor_api/message'
  autoload :NotificationOptions,     'fidor_api/notification_options'
  autoload :Msisdn,                  'fidor_api/msisdn'
  autoload :Password,                'fidor_api/password'
  autoload :Person,                  'fidor_api/person'
  autoload :Preauth,                 'fidor_api/preauth'
  autoload :PreauthDetails,          'fidor_api/preauth_details'
  autoload :Preference,              'fidor_api/preference'
  autoload :SessionToken,            'fidor_api/session_token'
  autoload :Token,                   'fidor_api/token'
  autoload :SddReturnTransaction,    'fidor_api/sdd_return_transaction'
  autoload :TransactionDetails,      'fidor_api/transaction_details'
  autoload :Transaction,             'fidor_api/transaction'
  autoload :Transfer,                'fidor_api/transfer'
  autoload :StandingOrder,           'fidor_api/standing_order'
  autoload :User,                    'fidor_api/user'
  autoload :Version,                 'fidor_api/version'
  autoload :Notification,            'fidor_api/notification'
  autoload :LegalDocumentAcceptance, 'fidor_api/legal_document_acceptance'

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

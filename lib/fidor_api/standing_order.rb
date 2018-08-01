module FidorApi
  module StandingOrder
    autoload :Email,         'fidor_api/standing_order/email'
    autoload :Phone,         'fidor_api/standing_order/phone'
    autoload :Sepa,          'fidor_api/standing_order/sepa'
    autoload :Base,          'fidor_api/standing_order/base'
    autoload :Generic,       'fidor_api/standing_order/generic'
  end
end

module FidorApi
  module Transfer
    module Legacy
      autoload :Base,     'fidor_api/transfer/legacy/base'
      autoload :Internal, 'fidor_api/transfer/legacy/internal'
      autoload :Sepa,     'fidor_api/transfer/legacy/sepa'
    end
  end
end

module FidorApi
  module Beneficiary
    class UaeInternational < Base
      include Generic

      attribute :account_number,   :string
      attribute :swift_code,       :string

      attribute :account_currency, :string
    end
  end
end

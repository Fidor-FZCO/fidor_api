module FidorApi
  module Beneficiary
    class DebitCard < Base
      include Generic

      attribute :destination,    :string
      attribute :account_type,   :string
      attribute :account_number, :string
      attribute :swift_code,     :string

      validates :destination,    presence: true, inclusion: { in: %w(internal external) }
      validates :account_type,   presence: true, inclusion: { in: %w(account card)      }
      validates :account_number, presence: true
      validates :swift_code,     presence: true
      validates :contact_name,   presence: true

      def set_attributes(attrs = {})
        self.destination    = attrs.fetch("routing_info", {})["destination"]
        self.account_type   = attrs.fetch("routing_info", {})["account_type"]
        self.account_number = attrs.fetch("routing_info", {})["account_number"]
        self.swift_code     = attrs.fetch("routing_info", {})["swift_code"]
        super(attrs.except("routing_type", "routing_info"))
      end

      def as_json_routing_type
        "direct_debit"
      end

      def as_json_routing_info
        {
          destination:    destination,
          account_type:   account_type,
          account_number: account_number,
          swift_code:     swift_code
        }
      end

      private

      module ClientSupport
        def build_uae_domestic_beneficiary(attributes = {})
          Beneficiary::DirectDebit.new(attributes)
        end
      end
    end
  end
end

module FidorApi
  module Transfer
    class UaeDomestic < Base
      include Generic

      attribute :account_number, :string
      attribute :swift_code,     :string

      validates :account_number, presence: true, unless: :beneficiary_reference_passed?
      validates :swift_code,     presence: true, unless: :beneficiary_reference_passed?

      def initialize(attrs = {})
        set_beneficiary_attributes(attrs)
        self.account_number = attrs.fetch("beneficiary", {}).fetch("routing_info", {})["account_number"]
        self.swift_code     = attrs.fetch("beneficiary", {}).fetch("routing_info", {})["swift_code"]
        super(attrs.except("beneficiary"))
      end

      def as_json_routing_type
        "UAE_DOMESTIC"
      end

      def as_json_routing_info
        {
          account_number: account_number,
          swift_code: swift_code
        }
      end

      module ClientSupport
        def uae_domestic_transfers(options = {})
          Transfer::UaeDomestic.all(token.access_token, options)
        end

        def uae_domestic_transfer(id)
          Transfer::UaeDomestic.find(token.access_token, id)
        end

        def build_uae_domestic_transfer(attributes = {})
          Transfer::UaeDomestic.new(attributes.merge(client: self))
        end

        def update_uae_domestic_transfer(id, attributes = {})
          Transfer::UaeDomestic.new(attributes.merge(client: self, id: id))
        end
      end
    end
  end
end

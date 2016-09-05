module FidorApi
  module Transfer
    class UaeDomestic < Base
      include Generic

      validates :contact_name, presence: true, unless: :beneficiary_reference_passed?

      attribute :account_number, :string
      attribute :swift_code,     :string

      validates :account_number, presence: true, unless: :beneficiary_reference_passed?
      validates :swift_code,     presence: true, unless: :beneficiary_reference_passed?

      attr_accessor :pending_transfer_id

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

      def create(options = {})
        if pending_transfer_id.present?
          options[:endpoint]     = "/pending_transfers/#{pending_transfer_id}/transfer"
          options[:htauth]       = true
          options[:access_token] = nil
        end
        super(options)
      end

      def self.find_by_pending_transfer(pending_transfer_id)
        new(request(access_token: nil, endpoint: "/pending_transfers/#{pending_transfer_id}/transfer", htauth: true).body)
      end

      module ClientSupport
        def uae_domestic_transfers(options = {})
          Transfer::UaeDomestic.all(token.access_token, options)
        end

        def uae_domestic_transfer(id)
          Transfer::UaeDomestic.find(token.access_token, id)
        end

        def uae_domestic_transfer_by_pending_transfer(pending_transfer_id)
          Transfer::UaeDomestic.find_by_pending_transfer(pending_transfer_id)
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

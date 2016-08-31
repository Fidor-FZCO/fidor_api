module FidorApi
  module Beneficiary
    class UaeDomestic < Base
      include Generic

      attribute :account_number, :string
      attribute :swift_code,     :string

      validates :contact_name,   presence: true
      validates :account_number, presence: true
      validates :swift_code,     presence: true

      def initialize(attrs = {})
        self.account_number = attrs.fetch("routing_info", {})["account_number"]
        self.swift_code     = attrs.fetch("routing_info", {})["swift_code"]
        super(attrs.except("routing_type", "routing_info"))
      end

      def save
        create
      end

      def as_json_routing_type
        "UAE_DOMESTIC"
      end

      def as_json_routing_info
        {
          account_number: account_number,
          swift_code:     swift_code
        }
      end

      private

      def self.resource
        "beneficiaries"
      end

      module ClientSupport
        def build_uae_domestic_beneficiary(attributes = {})
          Beneficiary::UaeDomestic.new(attributes.merge(client: self))
        end
      end
    end
  end
end

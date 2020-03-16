module FidorApi
  module Transfer
    class DebitCard < Base
      include Generic

      validates :contact_name, presence: true, unless: :beneficiary_reference_passed?

      attribute :destination,    :string
      attribute :account_type,   :string
      attribute :account_number, :string
      attribute :swift_code,     :string

      with_options unless: :beneficiary_reference_passed? do |inline|
        inline.validates :destination,    presence: true, inclusion: { in: %w(internal external) }
        inline.validates :account_type,   presence: true, inclusion: { in: %w(account card)      }
        inline.validates :account_number, presence: true
        inline.validates :swift_code,     presence: true
      end

      attr_accessor :pending_transfer_id

      def set_attributes(attrs = {})
        set_beneficiary_attributes(attrs)
        self.destination    = attrs.fetch("beneficiary", {}).fetch("routing_info", {})["destination"]
        self.account_type   = attrs.fetch("beneficiary", {}).fetch("routing_info", {})["account_type"]
        self.account_number = attrs.fetch("beneficiary", {}).fetch("routing_info", {})["account_number"]
        self.swift_code     = attrs.fetch("beneficiary", {}).fetch("routing_info", {})["swift_code"]
        super(attrs.except("beneficiary"))
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

      def self.find_by_pending_transfer(pending_transfer_id)
        response = Connectivity::Connection.get("/pending_transfers/#{pending_transfer_id}/transfer")
        new(response.body)
      end

      private

      def remote_create
        if pending_transfer_id.present?
          response = Connectivity::Connection.post("/pending_transfers/#{pending_transfer_id}/transfer", body: as_json)
        else
          response = endpoint.for(self).post(payload: self.as_json)
        end
        if path = response.headers["X-Fidor-Confirmation-Path"]
          self.confirmable_action = ConfirmableAction.new(id: path.split("/").last)
        end
        response
      end

      module ClientSupport
        def uae_domestic_transfers(options = {})
          Transfer::DebitCard.all(options)
        end

        def uae_domestic_transfer(id)
          Transfer::DebitCard.find(id)
        end

        def uae_domestic_transfer_by_pending_transfer(pending_transfer_id)
          Transfer::DebitCard.find_by_pending_transfer(pending_transfer_id)
        end

        def build_uae_domestic_transfer(attributes = {})
          Transfer::DebitCard.new(attributes)
        end

        def update_uae_domestic_transfer(id, attributes = {})
          Transfer::DebitCard.new(attributes.merge(id: id))
        end
      end
    end
  end
end

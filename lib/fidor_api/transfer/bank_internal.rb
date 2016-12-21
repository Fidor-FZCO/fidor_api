module FidorApi
  module Transfer
    class BankInternal < Base
      include Generic
      attribute :account_number, :string

      validates :account_number, presence: true, unless: :beneficiary_reference_passed?

      attr_accessor :pending_transfer_id

      def set_attributes(attrs = {})
        self.account_number = attrs.fetch("beneficiary", {}).fetch("routing_info", {})["account_number"]
        super(attrs)
      end

      def as_json_routing_type
        'BANK_INTERNAL'
      end

      def as_json_routing_info
        {
          account_number: account_number
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
    end
  end
end

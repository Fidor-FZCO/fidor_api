module FidorApi
  module Transfer
    class Pending < Connectivity::Resource
      include Generic

      self.endpoint = Connectivity::Endpoint.new('/pending_transfers', :collection)

      attribute :routing_type, :string
      attribute :routing_info, :json

      def set_attributes(attrs = {})
        set_beneficiary_attributes(attrs)

        self.routing_type = attrs.fetch("beneficiary", {})["routing_type"]
        self.routing_info = attrs.fetch("beneficiary", {})["routing_info"]

        super(attrs.except("beneficiary"))
      end

      module ClientSupport
        def pending_transfer(id)
          Transfer::Pending.find(id)
        end
      end
    end
  end
end

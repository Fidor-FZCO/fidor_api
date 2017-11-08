module FidorApi
  module Transfer
    class Pending < Connectivity::Resource
      include Generic

      self.endpoint = Connectivity::Endpoint.new('/pending_transfers', :collection)

      attribute :routing_type, :string
      attribute :routing_info, :json
      attribute :sender,       :json

      def set_attributes(attrs = {})
        self.routing_type = attrs.fetch('beneficiary', {})['routing_type']
        self.routing_info = attrs.fetch('beneficiary', {})['routing_info']
        self.sender       = attrs.fetch('sender', {})

        set_beneficiary_attributes(attrs)

        super(attrs.except('beneficiary'))
      end

      def as_json_routing_type
        self.routing_type
      end

      def as_json_routing_info
        self.routing_info
      end

      module ClientSupport
        def pending_transfer(id)
          Transfer::Pending.find(id)
        end
      end
    end
  end
end

module FidorApi
  module Transfer
    class Pending < Connectivity::Resource
      include Generic

      self.endpoint = Connectivity::Endpoint.new('/pending_transfers', :collection)

      def set_attributes(attrs = {})
        set_beneficiary_attributes(attrs)
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

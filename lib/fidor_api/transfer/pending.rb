module FidorApi
  module Transfer
    class Pending < Resource
      include Generic

      def initialize(attrs = {})
        set_beneficiary_attributes(attrs)
        super(attrs.except("beneficiary"))
      end

      def self.find(id)
        new(request(access_token: nil, endpoint: "/pending_transfers/#{id}", htauth: true).body)
      end

      module ClientSupport
        def pending_transfer(id)
          Transfer::Pending.find(id)
        end
      end
    end
  end
end

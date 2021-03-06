module FidorApi
  module StandingOrder
    class Phone < Base
      include Generic

      attribute :mobile_phone_number, :string

      validates :mobile_phone_number, presence: true, unless: :beneficiary_reference_passed?

      def set_attributes(attrs = {})
        set_schedule_attributes(attrs)
        set_beneficiary_attributes(attrs)
        self.mobile_phone_number = attrs.dig('beneficiary','routing_info', 'mobile_phone_number')
        super(attrs.except("beneficiary"))
      end

      def as_json_routing_type
        "FOS_P2P_PHONE"
      end

      def as_json_routing_info
        {
          mobile_phone_number: mobile_phone_number
        }
      end

      module ClientSupport
        def p2p_phone_transfers(options = {})
          Transfer::P2pPhone.all(options)
        end

        def p2p_phone_transfer(id)
          Transfer::P2pPhone.find(id)
        end

        def build_p2p_phone_transfer(attributes = {})
          Transfer::P2pPhone.new(attributes)
        end

        def update_p2p_phone_transfer(id, attributes = {})
          Transfer::P2pPhone.new(attributes.merge(id: id))
        end
      end
    end
  end
end

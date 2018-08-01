module FidorApi
  module StandingOrder
    class Email < Base
      include Generic

      attribute :email, :string

      validates :email, presence: true, unless: :beneficiary_reference_passed?

      def set_attributes(attrs = {})
        set_schedule_attributes(attrs)
        set_beneficiary_attributes(attrs)
        self.email = attrs.dig('beneficiary','routing_info', 'email')
        super(attrs.except("beneficiary"))
      end

      def as_json_routing_type
        "FOS_P2P_EMAIL"
      end

      def as_json_routing_info
        {
          email: email
        }
      end
    end
  end
end

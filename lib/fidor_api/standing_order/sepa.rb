module FidorApi
  module StandingOrder
    class Sepa < Base
      include Generic

      attribute :remote_iban, :string
      attribute :remote_bic,  :string

      validates :contact_name, presence: true, unless: :beneficiary_reference_passed?
      validates :remote_iban,  presence: true, unless: :beneficiary_reference_passed?

      def set_attributes(attrs = {})
        set_beneficiary_attributes(attrs)
        set_schedule_attributes(attrs)
        self.remote_iban = attrs.dig('beneficiary','routing_info', 'remote_iban')
        self.remote_bic  = attrs.dig('beneficiary','routing_info', 'remote_bic')
        super(attrs.except("beneficiary"))
      end

      def as_json_routing_type
        "SEPA"
      end

      def as_json_routing_info
        {
          remote_iban: remote_iban,
          remote_bic:  remote_bic
        }.compact
      end
    end
  end
end

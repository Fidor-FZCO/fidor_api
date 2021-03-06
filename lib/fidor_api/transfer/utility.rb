module FidorApi
  module Transfer
    class Utility < Base
      include Generic

      attribute :utility_provider,        :string
      attribute :utility_service,         :string
      attribute :utility_service_number,  :string
      attribute :inquiry_ref_num,         :string
      attribute :additional_fields,       :json

      validates :utility_provider,        presence: true, unless: :beneficiary_reference_passed?
      validates :utility_service,         presence: true, unless: :beneficiary_reference_passed?
      validates :utility_service_number,  presence: true, unless: :beneficiary_reference_passed?
      validates :inquiry_ref_num,         presence: true

      def set_attributes(attrs = {})
        self.beneficiary_unique_name = attrs.dig('beneficiary', 'unique_name')
        self.utility_provider        = attrs.dig('beneficiary', 'routing_info', 'utility_provider')
        self.utility_service         = attrs.dig('beneficiary', 'routing_info', 'utility_service')
        self.utility_service_number  = attrs.dig('beneficiary', 'routing_info', 'utility_service_number')
        self.additional_fields       = attrs.dig('beneficiary', 'routing_info', 'additional_fields')

        self.inquiry_ref_num = attrs.dig('additional_attributes', 'inquiry_ref_num')

        super(attrs.except("routing_type", "routing_info"))
      end

      def as_json_routing_type
        "UTILITY"
      end

      def as_json_routing_info
        {
          utility_provider:       utility_provider,
          utility_service:        utility_service,
          utility_service_number: utility_service_number,
          additional_fields:      additional_fields
        }
      end

      def as_json_additional_attributes
        (additional_attributes || {}).merge("inquiry_ref_num" => inquiry_ref_num)
      end

      private

      def remote_create
        response = endpoint.for(self).post(payload: self.as_json)

        if path = response.headers["X-Fidor-Confirmation-Path"]
          self.confirmable_action = ConfirmableAction.new(id: path.split("/").last)
        end

        response
      end
    end
  end
end

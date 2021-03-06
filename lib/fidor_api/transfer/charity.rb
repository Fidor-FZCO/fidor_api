module FidorApi
  module Transfer
    class Charity < Base
      include Generic

      attribute :utility_provider,        :string
      attribute :utility_service,         :string
      attribute :utility_service_number,  :string
      attribute :inquiry_ref_num,         :string

      validates :utility_provider,        presence: true, unless: :beneficiary_reference_passed?
      validates :utility_service,         presence: true, unless: :beneficiary_reference_passed?
      validates :utility_service_number,  presence: true, unless: :beneficiary_reference_passed?
      validates :inquiry_ref_num,         presence: true

      def set_attributes(attrs = {})
        self.utility_provider        = attrs.fetch("beneficiary", {}).fetch("routing_info", {})["utility_provider"]
        self.utility_service         = attrs.fetch("beneficiary", {}).fetch("routing_info", {})["utility_service"]
        self.utility_service_number  = attrs.fetch("beneficiary", {}).fetch("routing_info", {})["utility_service_number"]
        self.inquiry_ref_num         = attrs.fetch("beneficiary", {}).fetch("routing_info", {})["inquiry_ref_num"]
        super(attrs.except("routing_type", "routing_info"))
      end

      def as_json_routing_type
        "CHARITY"
      end

      def as_json_routing_info
        {
          utility_provider:        utility_provider,
          utility_service:         utility_service,
          utility_service_number:  utility_service_number,
          inquiry_ref_num:         inquiry_ref_num
        }
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

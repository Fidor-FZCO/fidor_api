module FidorApi
  module Beneficiary
    class Utility < Base
      include Generic

      attribute :utility_provider,        :string
      attribute :utility_service,         :string
      attribute :utility_service_number,  :string
      attribute :inquiry_ref_num,         :string
      attribute :additional_fields,       :json

      validates :utility_provider,        presence: true
      validates :utility_service,         presence: true
      validates :utility_service_number,  presence: true
      validates :unique_name,             presence: true

      def set_attributes(attrs = {})
        self.utility_provider        = attrs.fetch("routing_info", {})["utility_provider"]
        self.utility_service         = attrs.fetch("routing_info", {})["utility_service"]
        self.utility_service_number  = attrs.fetch("routing_info", {})["utility_service_number"]
        self.inquiry_ref_num         = attrs.fetch("routing_info", {})["inquiry_ref_num"]
        self.additional_fields       = attrs.fetch("routing_info", {})["additional_fields"]
        super(attrs.except("routing_type", "routing_info"))
      end

      def as_json_routing_type
        "UTILITY"
      end

      def as_json_routing_info
        {
          utility_provider:        utility_provider,
          utility_service:         utility_service,
          utility_service_number:  utility_service_number,
          inquiry_ref_num:         inquiry_ref_num,
          additional_fields:       additional_fields
        }
      end
    end
  end
end

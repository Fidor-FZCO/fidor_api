module FidorApi
  module Transfer
    class Fps < Base
      include Generic

      attribute :remote_account_number, :string
      attribute :remote_sort_code,      :string

      validates :contact_name,          presence: true, unless: :beneficiary_reference_passed?
      validates :remote_account_number, presence: true, unless: :beneficiary_reference_passed?
      validates :remote_sort_code,      presence: true, unless: :beneficiary_reference_passed?

      def set_attributes(attrs = {})
        set_beneficiary_attributes(attrs)
        self.remote_account_number = attrs.fetch("beneficiary", {}).fetch("routing_info", {})["remote_account_number"]
        self.remote_sort_code  = attrs.fetch("beneficiary", {}).fetch("routing_info", {})["remote_sort_code"]
        super(attrs.except("beneficiary"))
      end

      def as_json_routing_type
        "FPS"
      end

      def as_json_routing_info
        {
          remote_account_number: remote_account_number,
          remote_sort_code:      remote_sort_code
        }.compact
      end
    end
  end
end

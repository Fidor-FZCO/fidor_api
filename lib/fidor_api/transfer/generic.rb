module FidorApi
  module Transfer
    module Generic
      ROUTING_INFO_ERROR_PREFIX = "beneficiary.routing_info.".freeze

      module SetAttributes
        # validation_mode only allows booleans, so we have to cast eventual strings
        def set_attributes(attrs = {})
          ['validation_mode', :validation_mode].each do |k|
            next unless attrs[k]
            attrs[k] = convert_to_boolean attrs[k]
          end
          super attrs
        end

        private

        def convert_to_boolean(value)
          case value
          when 'true'
            true
          when 'false'
            false
          else
            value
          end
        end
      end

      def self.included(base)
        base.extend ModelAttribute
        base.extend AmountAttributes
        base.prepend SetAttributes

        base.validates *required_attributes, presence: true
        base.validates :beneficiary_unique_name, presence: true, if: -> { create_beneficiary && !beneficiary_reference_passed? }

        base.attribute :id,                      :string
        base.attribute :account_id,              :string
        base.attribute :external_uid,            :string
        base.attribute :subject,                 :string
        base.attribute :scheduled_date,          :string
        base.attribute :currency,                :string
        base.attribute :exchange_rate,           :string
        base.attribute :state,                   :string
        base.attribute :exchange_rate_fee,       :string
        base.attribute :additional_attributes,   :json
        base.amount_attribute                    :amount
        base.amount_attribute                    :beneficiary_amount

        base.attribute :beneficiary_unique_name, :string
        base.attribute :contact_name,            :string
        base.attribute :contact_address_line_1,  :string
        base.attribute :contact_address_line_2,  :string
        base.attribute :contact_city,            :string
        base.attribute :contact_country,         :string
        base.attribute :bank_name,               :string
        base.attribute :bank_address_line_1,     :string
        base.attribute :bank_address_line_2,     :string
        base.attribute :bank_city,               :string
        base.attribute :bank_country,            :string
        base.attribute :create_beneficiary,      :boolean

        base.attribute :beneficiary_id,          :string

        base.attribute :created_at,              :time
        base.attribute :updated_at,              :time

        base.attribute :validation_mode,         :boolean
      end

      def self.required_attributes
        [ :account_id, :external_uid, :amount, :currency ]
      end

      def as_json
        transfer_json_params.merge(beneficiary_json_params)
      end

      private

      def beneficiary_reference_passed?
        beneficiary_id.present?
      end

      def transfer_json_params
        {
          account_id: account_id,
          external_uid: external_uid,
          amount: (amount * 100).to_i,
          currency: currency,
          subject: subject,
          additional_attributes: as_json_additional_attributes,
          scheduled_date: scheduled_date,
          validation_mode: validation_mode ? true : false
        }.compact
      end

      def beneficiary_json_params
        if beneficiary_reference_passed?
          {
            beneficiary_id: beneficiary_id
          }
        else
          {
            beneficiary: {
              unique_name: beneficiary_unique_name.presence,
              contact: {
                name:           contact_name,
                address_line_1: contact_address_line_1,
                address_line_2: contact_address_line_2,
                city:           contact_city,
                country:        contact_country
              }.compact,
              bank: {
                name:           bank_name,
                address_line_1: bank_address_line_1,
                address_line_2: bank_address_line_2,
                city:           bank_city,
                country:        bank_country
              }.compact,
              routing_type: as_json_routing_type,
              routing_info: as_json_routing_info
            },
            create_beneficiary: create_beneficiary
          }.compact
        end
      end

      def as_json_additional_attributes
        additional_attributes
      end

      def set_beneficiary_attributes(attrs)
        self.beneficiary_unique_name   = attrs.fetch("beneficiary", {})["unique_name"]

        self.contact_name           = attrs.fetch("beneficiary", {}).fetch("contact", {})["name"]
        self.contact_address_line_1 = attrs.fetch("beneficiary", {}).fetch("contact", {})["address_line_1"]
        self.contact_address_line_2 = attrs.fetch("beneficiary", {}).fetch("contact", {})["address_line_2"]
        self.contact_city           = attrs.fetch("beneficiary", {}).fetch("contact", {})["city"]
        self.contact_country        = attrs.fetch("beneficiary", {}).fetch("contact", {})["country"]

        self.bank_name              = attrs.fetch("beneficiary", {}).fetch("bank",    {})["name"]
        self.bank_address_line_1    = attrs.fetch("beneficiary", {}).fetch("bank",    {})["address_line_1"]
        self.bank_address_line_2    = attrs.fetch("beneficiary", {}).fetch("bank",    {})["address_line_2"]
        self.bank_city              = attrs.fetch("beneficiary", {}).fetch("bank",    {})["city"]
        self.bank_country           = attrs.fetch("beneficiary", {}).fetch("bank",    {})["country"]
      end

      def map_errors(fields)
        fields.each do |hash|
          field = hash["field"].to_sym
          key   = hash["key"].try :to_sym
          limit = hash["options"] && hash["options"]["limit"]

          if field == :base || respond_to?(field)
            if key
              errors.add(field, key, message: hash["message"], limit: limit)
            else
              errors.add(field, hash["message"])
            end
          elsif hash["field"] == "beneficiary.unique_name"
            errors.add(:beneficiary_unique_name, key, message: hash["message"])
          elsif hash["field"].start_with?(ROUTING_INFO_ERROR_PREFIX)
            invalid_field = hash["field"][ROUTING_INFO_ERROR_PREFIX.size..-1]
            errors.add(invalid_field, hash["key"].to_sym, message: hash["message"])
          end
        end
      end
    end
  end
end

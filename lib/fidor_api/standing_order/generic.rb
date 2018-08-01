module FidorApi
  module StandingOrder
    module Generic
      ROUTING_INFO_ERROR_PREFIX = "beneficiary.routing_info.".freeze
      WEEKLY_RYTHMS = %w(weekly biweekly)

      def self.included(base)
        base.extend ModelAttribute
        base.extend AmountAttributes
        base.prepend FidorApi::Transfer::Generic::SetAttributes

        base.validates *required_attributes, presence: true
        base.validates :beneficiary_unique_name, presence: true, if: -> { create_beneficiary && !beneficiary_reference_passed? }
        base.validates :runtime_day_of_month, presence: true, if: -> { WEEKLY_RYTHMS.exclude? rhythm }
        base.validates :runtime_day_of_week, presence: true, if: -> { WEEKLY_RYTHMS.include? rhythm }

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

        base.attribute :rhythm,                  :string
        base.attribute :runtime_day_of_month,    :string
        base.attribute :runtime_day_of_week,     :string
        base.attribute :ultimate_run,            :string
        base.attribute :next_run,                :string
      end

      def as_json
        transfer_json_params.merge(beneficiary_json_params).merge(schedule_json_params)
      end

      private

      def self.required_attributes
        %i[account_id external_uid amount currency ultimate_run]
      end

      def set_schedule_attributes(attrs)
        self.rhythm                 = attrs.dig('schedule','rhythm')
        self.runtime_day_of_month   = attrs.dig('schedule','runtime_day_of_month')
        self.runtime_day_of_week    = attrs.dig('schedule','runtime_day_of_week')
        self.ultimate_run           = attrs.dig('schedule','ultimate_run')
        self.next_run               = attrs.dig('schedule','next_run')
      end

      def schedule_json_params
        {
          schedule: {
            rhythm: rhythm,
            runtime_day_of_month: runtime_day_of_month,
            runtime_day_of_week: runtime_day_of_week,
            ultimate_run: ultimate_run,
            next_run: next_run
          }
        }.compact
      end

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
          additional_attributes: additional_attributes,
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

      def set_beneficiary_attributes(attrs)
        self.beneficiary_unique_name = attrs.fetch('beneficiary', {})['unique_name']

        self.contact_name           = attrs.dig('beneficiary','contact', 'name')
        self.contact_address_line_1 = attrs.dig('beneficiary','contact', 'address_line_1')
        self.contact_address_line_2 = attrs.dig('beneficiary','contact', 'address_line_2')
        self.contact_city           = attrs.dig('beneficiary','contact', 'city')
        self.contact_country        = attrs.dig('beneficiary','contact', 'country')

        self.bank_name              = attrs.dig('beneficiary','bank', 'name')
        self.bank_address_line_1    = attrs.dig('beneficiary','bank', 'address_line_1')
        self.bank_address_line_2    = attrs.dig('beneficiary','bank', 'address_line_2')
        self.bank_city              = attrs.dig('beneficiary','bank', 'city')
        self.bank_country           = attrs.dig('beneficiary','bank', 'country')
      end

      def map_errors(fields)
        fields.each do |hash|
          field = hash['field'].to_sym
          key   = hash['key'].try :to_sym
          limit = hash['options'] && hash['options']['limit']

          if field == :base || respond_to?(field)
            if key
              errors.add(field, key, message: hash['message'], limit: limit)
            else
              errors.add(field, hash['message'])
            end
          elsif hash['field'] == 'beneficiary.unique_name'
            errors.add(:beneficiary_unique_name, key, message: hash['message'])
          elsif hash['field'].start_with?(ROUTING_INFO_ERROR_PREFIX)
            invalid_field = hash['field'][ROUTING_INFO_ERROR_PREFIX.size..-1]
            errors.add(invalid_field, hash['key'].to_sym, message: hash['message'])
          end
        end
      end
    end
  end
end

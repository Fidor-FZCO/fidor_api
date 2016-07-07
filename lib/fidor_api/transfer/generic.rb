module FidorApi
  module Transfer
    module Generic
      def self.included(base)
        base.extend ModelAttribute
        base.extend AmountAttributes

        base.validates *required_attributes, presence: true

        base.attribute :id,                     :string
        base.attribute :account_id,             :string
        base.attribute :external_uid,           :string
        base.attribute :contact_name,           :string
        base.attribute :contact_address_line_1, :string
        base.attribute :contact_address_line_2, :string
        base.attribute :contact_city,           :string
        base.attribute :contact_country,        :string
        base.attribute :bank_name,              :string
        base.attribute :bank_address_line_1,    :string
        base.attribute :bank_address_line_2,    :string
        base.attribute :bank_city,              :string
        base.attribute :bank_country,           :string
        base.attribute :subject,                :string
        base.attribute :currency,               :string
        base.attribute :subject,                :string
        base.attribute :state,                  :string
        base.attribute :created_at,             :time
        base.attribute :updated_at,             :time
        base.amount_attribute :amount

        base.singleton_class.instance_eval do
          define_method :resource do
            "transfers"
          end
        end
      end

      def self.required_attributes
        [ :account_id, :external_uid, :contact_name, :amount, :subject, :currency ]
      end

      def as_json
        {
          account_id: account_id,
          external_uid: external_uid,
          amount: (amount * 100).to_i,
          currency: currency,
          subject: subject,
          beneficiary: {
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
          }
        }
      end

      private

      def set_beneficiary_attributes(attrs)
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

      def contact
        (beneficiary || {}).fetch("contact", {})
      end

      def routing_info
        (beneficiary || {}).fetch("routing_info", {})
      end

      def map_errors(fields)
        fields.each do |hash|
          if respond_to? hash["field"].to_sym
            errors.add(hash["field"].to_sym, hash["message"])
          elsif hash["field"] == "beneficiary" && invalid_fields = hash["message"][/Invalid fields in routing_info: (.*)/, 1]
            invalid_fields.split(",").each do |invalid_field|
              errors.add(invalid_field, :invalid)
            end
          end
        end
      end
    end
  end
end

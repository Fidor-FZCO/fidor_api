module FidorApi
  class Customer < Connectivity::Resource
    extend ModelAttribute

    self.endpoint = Connectivity::Endpoint.new('/customers', :collection)

    module Gender
      extend self

      class Base
        include Singleton
      end

      class Male    < Base; end
      class Female  < Base; end
      class Unknown < Base; end

      MAPPING = {
        Male   => "m",
        Female => "f"
      }

      def for_api_value(api_value)
        MAPPING.key(api_value) || Unknown
      end

      def object_to_string(object)
        MAPPING[object]
      end
    end

    attribute :id,                             :integer
    attribute :customer_number,                :integer
    attribute :email,                          :string
    attribute :first_name,                     :string
    attribute :last_name,                      :string
    attribute :gender,                         :string
    attribute :title,                          :string
    attribute :nick,                           :string
    attribute :maiden_name,                    :string
    attribute :adr_street,                     :string
    attribute :adr_street_number,              :string
    attribute :adr_post_code,                  :string
    attribute :adr_city,                       :string
    attribute :adr_country,                    :string
    attribute :adr_phone,                      :string
    attribute :adr_mobile,                     :string
    attribute :adr_fax,                        :string
    attribute :adr_businessphone,              :string
    attribute :birthday,                       :time
    attribute :is_verified,                    :boolean
    attribute :nationality,                    :string
    attribute :marital_status,                 :integer
    attribute :religion,                       :integer
    attribute :id_card_registration_city,      :string
    attribute :id_card_number,                 :string
    attribute :id_card_valid_until,            :time
    attribute :created_at,                     :time
    attribute :updated_at,                     :time
    attribute :creditor_identifier,            :string
    attribute :affiliate_uid,                  :string
    attribute :verification_token,             :string
    attribute :password,                       :string
    attribute :tos,                            :boolean
    attribute :privacy_policy,                 :boolean
    attribute :own_interest,                   :boolean
    attribute :us_citizen,                     :boolean
    attribute :us_tax_payer,                   :boolean
    attribute :preferred_language,             :string
    attribute :community_user_picture,         :string
    attribute :country_of_birth,               :string
    attribute :additional_first_name,          :string
    attribute :occupation,                     :integer
    attribute :birthplace,                     :string
    attribute :invited_by_id,                  :string
    attribute :community_terms_and_conditions, :boolean
    attribute :additional_nationalities,       :json
    attribute :newsletter,                     :boolean
    attribute :campaign_name,                  :string

    def self.first
      all(page: 1, per_page: 1).first
    end

    def initialize(*args)
      self.affiliate_uid = FidorApi.configuration.affiliate_uid
      super
    end

    def request_update(attributes)
      self.endpoint = Connectivity::Endpoint.new('/customers', :collection, version: '2')
      endpoint.for(self).put(action: 'request_update', payload: attributes.as_json)
      true
    rescue ValidationError => e
      map_errors(e.fields)
      false
    end

    def confirm_update(attributes)
      self.endpoint = Connectivity::Endpoint.new('/customers', :collection, version: '2')
      endpoint.for(self).put(action: 'confirm_update', payload: {token: attributes['token']})
    end

    def gender
      Gender.for_api_value(@gender)
    end

    def gender=(value)
      @gender = if value.class == Class && value.instance.is_a?(FidorApi::Customer::Gender::Base)
        Gender.object_to_string(value)
      else
        value
      end
    end

    def as_json(options = nil)
      attributes.tap { |a| a[:birthday] = a[:birthday].try(:to_date) }
    end

    def save(anonymous: true)
      return false unless valid?

      remote_operation_result_body = persisted? ? remote_update(changes.keys).body : remote_create(anonymous).body
      remote_operation_result_body = {} if remote_operation_result_body.blank?
      set_attributes(remote_operation_result_body)
      true
    rescue ValidationError => e
      self.error_keys = e.error_keys
      map_errors(e.fields)
      false
    end

    private

    def remote_create(anonymous)
      endpoint.for(self).post(payload: self.as_json, anonymous: anonymous)
    end

    module ClientSupport
      def customers(options = {})
        Customer.all(options)
      end

      def first_customer
        Customer.first
      end

      def update_customer(id, attributes)
        Customer.endpoint.for(id).put(payload: attributes)
      end

      def request_customer_update(id, attributes)
        Customer.new(id: id).request_update(attributes)
      end

      def confirm_customer_update(id, attributes)
        Customer.new(id: id).confirm_update(attributes)
      end
    end
  end
end

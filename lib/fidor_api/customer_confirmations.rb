module FidorApi
  module CustomerConfirmations
    extend self

    END_POINT = '/customer_confirmations'.freeze

    def create_confirmation_token(type, resource)
      Connectivity::Connection.post(END_POINT, body: build_payload(type, resource))
    end

    def confirm_resource(type, resource, code)
      Connectivity::Connection.put(END_POINT, body: build_payload(type, resource, code))
    end

    private

    def build_payload(type, resource, code = nil)
      payload = if type == 'email'
        {type: 'email', email: resource}
      elsif type == 'mobile_phone'
        {type: 'mobile_phone', msisdn: resource}
      end
      payload[:token] = code if code.present? && payload.present?

      payload
    end
  end
end

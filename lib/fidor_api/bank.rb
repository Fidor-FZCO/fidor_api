module FidorApi
  class Bank < FidorApi::Connectivity::Resource
    self.endpoint = Connectivity::Endpoint.new('/bank_check', :resource)

    attr_accessor :bic, :name

    def self.find_by_iban(iban)
      result = endpoint.for(self).get(query_params: {iban: iban})

      new(
        bic:  result.body['bic'],
        name: result.body['bank_name']
      )
    rescue FidorApi::ValidationError
    end
  end
end

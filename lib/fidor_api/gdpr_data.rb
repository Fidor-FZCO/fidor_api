module FidorApi
  class GdprData < Connectivity::Resource

    self.endpoint = Connectivity::Endpoint.new('/gdpr_data', :collection)

    def self.attachment
      response = endpoint.for(self).get(anonymous: false)
    end

  end
end

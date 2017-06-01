module FidorApi
  class Notification < Connectivity::Resource
    extend ModelAttribute

    self.endpoint = Connectivity::Endpoint.new('/notifications/push', :collection)

    attribute :type,                :string

    def initialize(*args)
      super
    end

    def notify(type)
      self.type = type
      endpoint.for(self).post(payload: create_payload, tokenless: false)
    end

    private
    
    def create_payload
      self.attributes
    end
  end
end

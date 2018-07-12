module FidorApi
  class Preference < Connectivity::Resource
    extend ModelAttribute

    self.endpoint = Connectivity::Endpoint.new('/preferences', :collection)

    attribute :preferred_language, :string
  end
end

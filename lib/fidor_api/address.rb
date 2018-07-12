module FidorApi
  class Address < Connectivity::Resource
    extend ModelAttribute

    self.endpoint = Connectivity::Endpoint.new('/persons/:id/addresses', :collection)

    attribute :id,                    :integer
    attribute :street,                :string
    attribute :street_nr,             :string
    attribute :city,                  :string
    attribute :postal_code,           :string
    attribute :country,               :string
  end
end

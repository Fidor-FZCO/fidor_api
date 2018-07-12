module FidorApi
  class Person < Connectivity::Resource
    extend ModelAttribute

    self.endpoint = Connectivity::Endpoint.new('/persons', :collection)

    attribute :id,                      :integer
    attribute :first_name,              :string
    attribute :last_name,               :string
    attribute :middle_name,             :string
    attribute :salutation,              :string
    attribute :gender,                  :string
    attribute :nationality,             :string
    attribute :date_of_birth,           :string
    attribute :occupation,              :string
  end
end

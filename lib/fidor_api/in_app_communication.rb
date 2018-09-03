module FidorApi
  class InAppCommunication < Connectivity::Resource
    extend ModelAttribute

    self.endpoint = Connectivity::Endpoint.new('/in_app_communications', :collection)

    attribute :id,                   :integer
    attribute :active,               :boolean
    attribute :title,                :string
    attribute :body,                 :string
    attribute :description,          :string
    attribute :link_url,             :string
    attribute :link_external,        :boolean
    attribute :background_image_url, :string
    attribute :platform,             :string
    attribute :expiration_date,      :time
    attribute :created_at,           :time
    attribute :updated_at,           :time

    module ClientSupport
      def in_app_communications(options = {})
        InAppCommunication.all(options)
      end
    end
  end
end

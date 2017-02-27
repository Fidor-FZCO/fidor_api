module FidorApi
  class NotificationOptions < Connectivity::Resource
    extend ModelAttribute

    self.endpoint = Connectivity::Endpoint.new('/accounts/:id/notification_options', :resource)

    attribute :id, :integer
    attribute :ebox_message_document_email, :boolean
    attribute :ebox_message_document_sms, :boolean
    attribute :ebox_message_information_email, :boolean
    attribute :ebox_message_information_sms, :boolean
    attribute :ebox_message_advantage_offer_email, :boolean
    attribute :ebox_message_advantage_offer_sms, :boolean
    attribute :ebox_document_storage_alert_email, :boolean
    attribute :ebox_document_storage_alert_sms, :boolean
  end
end

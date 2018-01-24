module FidorApi
  module LegalDocumentAcceptance
    class Acceptance < Connectivity::Resource
      extend ModelAttribute

      self.endpoint = Connectivity::Endpoint.new('/legal_document_acceptances', :collection)

      def accept(document_type:)
        params = {legal_document: document_type}
        response = endpoint.for(self).post(payload: params)
        response
      end
    end

    module ClientSupport
      def accept_legal_document(document_type:)
        Acceptance.new.accept(document_type: document_type)
      end
    end
  end
end

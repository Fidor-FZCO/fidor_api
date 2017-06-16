module FidorApi
  class SddReturnTransaction < Connectivity::Resource
    extend ModelAttribute
    extend AmountAttributes

    self.endpoint = Connectivity::Endpoint.new('/transactions/:transaction_id/debit_return', :resource)

    attr_accessor :transaction_id
    attribute :reason, :string

    def confirm
      endpoint.for(self).put(action: :confirm)
    end

    def persisted?
      false
    end

    def as_json
      attributes.slice(:reason)
    end
  end
end

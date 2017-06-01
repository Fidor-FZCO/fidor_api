module FidorApi
  class Bonus < Connectivity::Resource
    extend ModelAttribute
    extend AmountAttributes

    self.endpoint = Connectivity::Endpoint.new('/bonuses', :collection)

    attribute :name, :string
    attribute :category, :string
    attribute :maximum_events_per_month, :integer
    attribute :granted_events, :integer
    attribute :pending_events, :integer
    amount_attribute :current_amount_per_event
    amount_attribute :granted_amount
    amount_attribute :pending_amount

    module ClientSupport
      def bonuses(options = {})
        Bonus.all(options)
      end
    end
  end
end

module FidorApi
  module Transfer
    class Base < Connectivity::Resource
      self.endpoint = Connectivity::Endpoint.new('/transfers', :collection)

      attr_accessor :confirmable_action

      def save
        fail InvalidRecordError unless valid?
        super
      end

      def needs_confirmation?
        self.confirmable_action.present?
      end

      def validate_remote
        params = { query_params: { validation_mode: true } }
        persisted? ? remote_update(params) : remote_create(params)

        true
      rescue ValidationError => e
        self.error_keys = e.error_keys
        map_errors(e.fields)
        false
      end

      private

      def remote_create(params = {})
        response = super
        if path = response.headers["X-Fidor-Confirmation-Path"]
          self.confirmable_action = ConfirmableAction.new(id: path.split("/").last)
        end
        response
      end

      def remote_update(*attributes)
        response = super
        if path = response.headers["X-Fidor-Confirmation-Path"]
          self.confirmable_action = ConfirmableAction.new(id: path.split("/").last)
        end
        response
      end
    end
  end
end

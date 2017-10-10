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
        @_validation_mode = validation_mode if respond_to?(:validation_mode)
        self.validation_mode = true if respond_to?(:validation_mode=)
        if persisted?
          endpoint.for(self).put(payload: as_json, query_params: {validation_mode: true})
        else
          endpoint.for(self).post(payload: as_json, query_params: {validation_mode: true})
        end
        true
      rescue ValidationError => e
        self.error_keys = e.error_keys
        map_errors(e.fields)
        false
      ensure
        self.validation_mode = @_validation_mode if respond_to?(:validation_mode=)
      end

      private

      def remote_create
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

module FidorApi
  module StandingOrder
    class Base < Connectivity::Resource
      self.endpoint = Connectivity::Endpoint.new('/standing_orders', :collection)

      class << self
        def new(hash={})
          if self == Base
            class_for_response_hash(hash).new hash
          else
            super
          end
        end

        private

        def class_for_response_hash(hash)
          ROUTING_TYPE_CLASSES.fetch(hash["beneficiary"]["routing_type"]).constantize
        end
      end

      attr_accessor :confirmable_action


      ROUTING_INFO_ERROR_PREFIX = "routing_info.".freeze

      ROUTING_TYPE_CLASSES = {
        "FOS_P2P_PHONE"          => "FidorApi::StandingOrder::Phone",
        "FOS_P2P_EMAIL"          => "FidorApi::StandingOrder::Email",
        "SEPA"                   => "FidorApi::StandingOrder::Sepa",
      }
      def save
        raise InvalidRecordError unless valid?
        super
      end

      def destroy
        endpoint.for(self.id).delete
      end

      def needs_confirmation?
        confirmable_action.present?
      end

      def validate_remote
        @_validation_mode = validation_mode if respond_to?(:validation_mode)
        self.validation_mode = true if respond_to?(:validation_mode=)
        if persisted?
          endpoint.for(self).put(payload: as_json, query_params: { validation_mode: true })
        else
          endpoint.for(self).post(payload: as_json, query_params: { validation_mode: true })
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
        if path = response.headers['X-Fidor-Confirmation-Path']
          self.confirmable_action = ConfirmableAction.new(id: path.split('/').last)
        end
        response
      end

      def remote_update(*attributes)
        response = super
        if path = response.headers['X-Fidor-Confirmation-Path']
          self.confirmable_action = ConfirmableAction.new(id: path.split('/').last)
        end
        response
      end
    end
  end
end

module FidorApi
  module Connectivity
    class Endpoint
      attr_reader :collection, :resource, :version, :anonymous, :mode

      def initialize(path, mode, version: '1', anonymous: false)
        @path = path
        @version = version
        @anonymous = anonymous
        @mode = mode

        case mode
        when :collection
          @collection = path
          @resource = "#{path}/:id"
        when :resource
          @resource = path
        else
          fail ArgumentError, "mode #{mode.inspect} must be resource or collection"
        end
      end

      class Context
        def initialize(endpoint, object)
          @endpoint = endpoint
          @object = object
        end

        def get(target: :resource, action: nil, query_params: nil, anonymous: nil)
          request :get, target, action, query_params: query_params, anonymous: anonymous
        end

        def post(target: @endpoint.mode, action: nil, payload: nil, anonymous: nil, query_params: nil)
          request :post, target, action, body: payload, anonymous: anonymous, query_params: query_params
        end

        def put(target: :resource, action: nil, payload: nil, anonymous: nil, query_params: nil)
          request :put, target, action, body: payload, anonymous: anonymous, query_params: query_params
        end

        def delete(target: :resource, action: nil, anonymous: nil)
          request :delete, target, action, anonymous: anonymous
        end

        private

        def request(method, target, action, options = {})
          options.reverse_merge! version: @endpoint.version
          options[:access_token] = nil if options[:anonymous] || @endpoint.anonymous
          Connection.public_send(method, send("#{target}_path", action), options)
        end

        def resource_path(action = nil)
          interpolate(@endpoint.resource, action)
        end

        def collection_path(action = nil)
          interpolate(@endpoint.collection, action)
        end

        def interpolate(path, suffix = nil)
          [path, suffix].compact.join('/').gsub(/:(\w+)/) do |m|
            fetch_option $1
          end
        end

        def fetch_option(name)
          if @object.kind_of? Hash
            @object[name]
          elsif @object.class.name.in?(INTEGER_CLASSES) || @object.kind_of?(String)
            @object
          elsif @object.respond_to? name
            @object.public_send name
          end
        end
      end

      def for(object)
        Context.new(self, object)
      end
    end
  end
end

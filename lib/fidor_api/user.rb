module FidorApi
  class User < Connectivity::Resource
    extend ModelAttribute

    self.endpoint = Connectivity::Endpoint.new('/users', :collection)

    attribute :id,                      :integer
    attribute :email,                   :string
    attribute :msisdn,                  :string
    attribute :password,                :string
    attribute :affiliate_uid,           :string
    attribute :msisdn_activated_at,     :time
    attribute :last_sign_in_at,         :string
    attribute :created_at,              :time
    attribute :updated_at,              :time
    attribute :friend_count,            :integer
    attribute :friend_of_friend_count,  :integer


    def initialize(*args)
      super
      self.affiliate_uid = FidorApi.configuration.affiliate_uid
    end

    def self.current
      new endpoint.for(self).get(action: 'current').body
    end

    private

    def remote_create
      endpoint.for(self).post(payload: create_payload, tokenless: true)
    end

    def create_payload
      self.attributes.slice(:email, :msisdn, :password, :affiliate_uid)
    end

    module ClientSupport
      def current_user
        User.current
      end
    end
  end
end

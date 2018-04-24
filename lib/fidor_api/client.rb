module FidorApi

  class Client
    include ActiveModel::Model

    attr_accessor :token

    include Account::ClientSupport
    include Beneficiary::ACH::ClientSupport
    include Beneficiary::ClientSupport
    include Beneficiary::UaeDomestic::ClientSupport
    include Bonus::ClientSupport
    include ConfirmableAction::ClientSupport
    include Customer::ClientSupport
    include LegalDocumentAcceptance::ClientSupport
    include Message::ClientSupport
    include Preauth::ClientSupport
    include SessionToken::ClientSupport
    include Transaction::ClientSupport
    include Transfer::ACH::ClientSupport
    include Transfer::FPS::ClientSupport
    include Transfer::Legacy::Internal::ClientSupport
    include Transfer::Legacy::Sepa::ClientSupport
    include Transfer::P2pAccountNumber::ClientSupport
    include Transfer::P2pPhone::ClientSupport
    include Transfer::P2pUsername::ClientSupport
    include Transfer::Pending::ClientSupport
    include Transfer::UaeDomestic::ClientSupport
    include User::ClientSupport
  end

end

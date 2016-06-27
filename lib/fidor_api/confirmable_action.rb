module FidorApi
  class ConfirmableAction
    include ActiveModel::Model

    attr_accessor :id, :resource
  end
end

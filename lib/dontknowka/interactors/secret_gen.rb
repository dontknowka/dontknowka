require 'securerandom'

require 'hanami/interactor'

class SecretGen
  include Hanami::Interactor

  expose :secret

  def initialize
  end

  def call()
    @secret = SecureRandom.hex(16)
  end
end

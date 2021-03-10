require 'openssl'
require 'rack'

def compare(a, b)
  Rack::Utils.secure_compare(a, b)
end

module Events
  module Verification
    def self.included(action)
      action.class_eval do
        before :verify_signature
      end
    end

    private

    def verify_signature
      signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), ENV['WEBHOOK_SECRET_TOKEN'], request.body.read)
      halt 500, "Signatures didn't match" unless compare(signature, request.env['HTTP_X_HUB_SIGNATURE_256'])
    end
  end
end

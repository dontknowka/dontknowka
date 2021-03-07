module Web
  module Controllers
    module Sessions
      class New
        include Web::Action

        expose :client_id
        expose :secret

        def initialize(secret_gen: SecretGen.new, client_id: ENV['LOGIN_CLIENT_ID'])
          @secret_gen = secret_gen
          @client_id = client_id
        end

        def call(params)
          @secret = @secret_gen.call().secret
          session[:auth_secret] = @secret
        end
      end
    end
  end
end

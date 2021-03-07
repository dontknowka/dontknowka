module Web
  module Controllers
    module Home
      class Auth
        include Web::Action

        def initialize(passcode: ENV['ORG_PASSCODE'])
          @passcode = passcode
        end

        def call(params)
        end
      end
    end
  end
end

module Admin
  module Controllers
    module Home
      class Auth
        include Admin::Action

        def initialize(password: ENV['ADMIN_PASSWORD'])
          @password = password
        end

        def call(params)
          halt 403 unless @password == params[:login][:password]
          session[:logged_in] = true
          redirect_to routes.root_path
        end

        private

        def authenticate?
        end
      end
    end
  end
end

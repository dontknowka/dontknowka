module Web
  module Controllers
    module Sessions
      class Auth
        include Web::Action

        def initialize(get_access_token: GetAccessToken.new)
          @get_access_token = get_access_token
        end

        def call(params)
          if session[:auth_secret] != params[:state]
            halt 403
          end
          session[:auth_secret] = nil
          result = @get_access_token.call(params[:code], params[:state])
          if result.valid
            session[:access_token] = result.token
            redirect_to routes.root_path
          else
            halt 403
          end
        end
      end
    end
  end
end

module Web
  module Authentication
    def self.included(action)
      action.class_eval do
        before :authenticate?
      end
    end

    private

    def authenticate?
      authenticate! if session[:access_token].nil?
    end

    def authenticate!
      redirect_to routes.login_path
    end
  end
end

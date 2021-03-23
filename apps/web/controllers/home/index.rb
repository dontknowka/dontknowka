module Web
  module Controllers
    module Home
      class Index
        include Web::Action

        before :authenticate?

        def initialize(fetch_user: FetchUser.new, get_user_role: GetUserRole.new)
          @fetch_user = fetch_user
          @get_user_role = get_user_role
        end

        def call(params)
          result = @fetch_user.call(session[:access_token])
          if result.valid
            session[:login] = result.login
            session[:email] = result.email
            session[:name] = result.name
            session[:avatar] = result.avatar
            session[:github_id] = result.github_id
            session[:role] = @get_user_role.call(result.login).role
            case session[:role]
            when 'student'
              redirect_to routes.student_path
            when 'teacher'
              redirect_to routes.teacher_path
            else
              halt 404, "Unknown role: #{session[:role]}"
            end
          else
            session[:access_token] = nil
            authenticate!
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
  end
end

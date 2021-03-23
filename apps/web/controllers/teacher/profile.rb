module Web
  module Controllers
    module Teacher
      class Profile
        include Web::Action

        before :authenticate?

        expose :login
        expose :avatar
        expose :teacher

        def initialize(teachers: TeacherRepository.new)
          @teachers = teachers
        end

        def call(params)
          id = session[:github_id]
          name = session[:name] || ''
          email = session[:email] || ''
          @teacher = @teachers.find(id)
          if @teacher.nil?
            if params[:teacher]
              @teacher = @teachers.create(id: id,
                                          login: session[:login],
                                          avatar: session[:avatar],
                                          first_name: params[:teacher][:first_name],
                                          last_name: params[:teacher][:last_name],
                                          email: params[:teacher][:email])
            else
              name_parts = name.split
              @teacher = Teacher.new(id: id,
                                     login: session[:login],
                                     avatar: session[:avatar],
                                     first_name: name_parts[0],
                                     last_name: name_parts[1],
                                     email: email)
            end
          else
            if params[:teacher]
              @teacher = @teachers.update(id, { first_name: params[:teacher][:first_name],
                                                last_name: params[:teacher][:last_name],
                                                email: params[:teacher][:email] })
            end
          end
          @login = session[:login]
          @avatar = session[:avatar]
        end

        private

        def authenticate?
          authenticate! if session[:login].nil?
        end

        def authenticate!
          redirect_to routes.login_path
        end
      end
    end
  end
end

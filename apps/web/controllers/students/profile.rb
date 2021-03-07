module Web
  module Controllers
    module Students
      class Profile
        include Web::Action

        before :authenticate?

        expose :login
        expose :profile
        expose :home
        expose :avatar
        expose :student

        def initialize(students: StudentRepository.new)
          @students = students
        end

        def call(params)
          id = session[:github_id]
          name = session[:name] || ''
          email = session[:email] || ''
          @student = @students.find(id)
          if @student.nil?
            if params[:student]
              @student = @students.create({ id: id,
                                            login: session[:login],
                                            avatar: session[:avatar],
                                            first_name: params[:student][:first_name],
                                            last_name: params[:student][:last_name],
                                            email: params[:student][:email],
                                            group: params[:student][:group] })
            else
              name_parts = name.split
              @student = Student.new(login: session[:login], first_name: name_parts[0], last_name: name_parts[1], email: email)
            end
          else
            if params[:student]
              @student = @students.update(id,
                                          { first_name: params[:student][:first_name],
                                            last_name: params[:student][:last_name],
                                            email: params[:student][:email],
                                            group: params[:student][:group] })
            end
          end
          @login = session[:login]
          @avatar = session[:avatar]
          @profile = routes.student_profile_path
          @home = routes.student_path
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

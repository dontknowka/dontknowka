module Web
  module Controllers
    module Students
      class Home
        include Web::Action

        before :authenticate?

        expose :student # FIXME: is this exposure really used in view/template?
        expose :avatar
        expose :login
        expose :home
        expose :profile
        expose :homeworks
        expose :total_score

        def initialize(check_membership: CheckMembership.new,
                       students: StudentRepository.new,
                       get_student_homework: GetStudentHomework.new,
                       get_student_score: GetStudentScore.new)
          @check_membership = check_membership
          @students = students
          @get_student_homework = get_student_homework
          @get_student_score = get_student_score
        end

        def call(params)
          if session[:role] != 'student'
            redirect_to routes.root_path
          end
          student = @students.find(session[:github_id])
          if student.nil?
            if @check_membership.call(session[:login]).result
              redirect_to routes.student_profile_path
            else
              redirect_to routes.new_student_auth_path
            end
          end
          @student = @students.update(student.id,
                                      login: session[:login],
                                      avatar: session[:avatar])
          @login = @student.login
          @avatar = @student.avatar
          @profile = routes.student_profile_path
          @home = routes.student_path

          @homeworks = @get_student_homework.call(@student).list
          @total_score = @get_student_score.call(@student).total
        end

        private

        def authenticate?
          authenticate! if session[:github_id].nil?
        end

        def authenticate!
          redirect_to routes.login_path
        end
      end
    end
  end
end

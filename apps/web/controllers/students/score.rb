module Web
  module Controllers
    module Students
      class Score
        include Web::Action

        expose :total_score
        expose :home
        expose :profile
        expose :login
        expose :avatar

        def initialize(students: StudentRepository.new,
                       get_student_score: GetStudentScore.new)
          @students = students
          @get_student_score = get_student_score
        end

        def call(params)
          student = @students.find(session[:github_id])
          halt 404 if student.nil?
          @total_score = @get_student_score.call(student).total
          @login = student.login
          @avatar = student.avatar
          @profile = routes.student_profile_path
          @home = routes.student_path
        end
      end
    end
  end
end

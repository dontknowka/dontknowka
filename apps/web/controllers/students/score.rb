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

        expose :bonuses
        expose :assignments

        def initialize(student_repo: StudentRepository.new,
                       get_student_score: GetStudentScore.new)
          @student_repo = student_repo
          @get_student_score = get_student_score
        end

        def call(params)
          student = @student_repo.find(session[:github_id])
          halt 404 if student.nil?
          score = @get_student_score.call(student)
          @total_score = score.total
          @login = student.login
          @avatar = student.avatar
          @profile = routes.student_profile_path
          @home = routes.student_path

          @bonuses = score.bonuses
          @assignments = score.assignments
        end
      end
    end
  end
end

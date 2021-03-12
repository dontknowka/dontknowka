module Admin
  module Controllers
    module Students
      class Index
        include Admin::Action

        expose :students
        expose :scores

        def initialize(student_repo: StudentRepository.new,
                       get_student_score: GetStudentScore.new)
          @student_repo = student_repo
          @get_student_score = get_student_score
        end

        def call(params)
          @students = @student_repo.ordered
          @scores = @students.reduce(Hash[]) {|h, s| h.merge({s.id => @get_student_score.call(s).total})}
        end
      end
    end
  end
end

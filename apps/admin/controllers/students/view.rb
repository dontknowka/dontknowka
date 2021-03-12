module Admin
  module Controllers
    module Students
      class View
        include Admin::Action

        expose :student
        expose :assignments
        expose :total_score
        expose :bonuses

        def initialize(students: StudentRepository.new,
                       get_student_score: GetStudentScore.new)
          @students = students
          @get_student_score = get_student_score
        end

        def call(params)
          @student = @students.find(params[:id])
          halt 404 if @student.nil?
          score_data = @get_student_score.call(@student)
          @total_score = score_data.total
          @bonuses = score_data.bonuses
          @assignments = score_data.assignments
        end
      end
    end
  end
end

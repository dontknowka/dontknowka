module Web
  module Controllers
    module Students
      class UseLateDays
        include Web::Action

        expose :login
        expose :profile
        expose :home
        expose :avatar
        expose :total_score

        expose :error
        expose :assignment
        expose :old_prepare
        expose :new_prepare
        expose :old_approve
        expose :new_approve
        expose :new_late_days

        def initialize(students: StudentRepository.new,
                       get_student_score: GetStudentScore.new)
          @students = students
          @get_student_score = get_student_score
        end

        def call(params)
          halt 404 if params[:assignment].nil?
          halt 403 if session[:login].nil?
          id = session[:github_id]
          student = @students.find(id)
          halt 403 if student.nil?

          @login = session[:login]
          @avatar = session[:avatar]
          @home = routes.student_path
          @profile = routes.student_profile_path
          @total_score = @get_student_score.call(student).total

          @assignment = params[:assignment]
          days = Integer(@assignment[:days])
          if student.late_days < 1
            @error = "You don't have any late days left, sorry"
          elsif days < 1 || days > student.late_days
            @error = "Days value must be between 1 and #{student.late_days}"
          else
            @new_late_days = student.late_days - days
            now = Time.now
            @old_prepare = Time.parse(@assignment[:prepare_deadline])
            @old_approve = Time.parse(@assignment[:approve_deadline])
            if @old_prepare > now
              @new_prepare = @old_prepare + 86400 * days
            end
            if @old_approve > now
              @new_approve = @old_approve + 86400 * days
            end
            if @new_prepare.nil? && @new_approve.nil?
              @error = "Not applicable to this assignment: both deadlines have passed"
            end
          end
        end
      end
    end
  end
end

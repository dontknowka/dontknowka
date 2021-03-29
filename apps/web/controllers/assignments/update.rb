module Web
  module Controllers
    module Assignments
      class Update
        include Web::Action

        def initialize(assignments: AssignmentRepository.new, students: StudentRepository.new)
          @assignments = assignments
          @students = students
        end

        def call(params)
          if params[:assignment]
            a = params[:assignment]
            id = Integer(a[:id])
            assignment = @assignments.find(id)
            if !assignment.nil?
              student = @students.find(assignment.student_id)
              if !student.nil?
                days = Integer(a[:days])
                if days > 0 && days <= student.late_days
                  now = Time.now
                  update = Hash[]
                  if now < assignment.prepare_deadline
                    update[:prepare_deadline] = assignment.prepare_deadline + days * 86400
                  end
                  if now < assignment.approve_deadline
                    update[:approve_deadline] = assignment.approve_deadline + days * 86400
                  end
                  @assignments.update(assignment.id, update)
                  @students.update(student.id, late_days: (student.late_days - days))
                else
                  Hanami.logger.warn "Applied late days number exceed range: #{days} vs [1..#{student.late_days}]"
                end
              else
                Hanami.logger.warn "No such student: #{assignment.student_id}"
              end
            else
              Hanami.logger.warn "No such assignment: #{id}"
            end
          end
          redirect_to routes.student_path
        end
      end
    end
  end
end

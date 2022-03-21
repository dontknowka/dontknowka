module Web
  module Controllers
    module Assignments
      class Update
        include Web::Action

        expose :error

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
                new_late_days = Integer(a[:new_late_days])
                update_prepare = a[:update_prepare] == '1'
                update_approve = a[:update_approve] == '1'
                if days > 0 && days <= student.late_days
                  if new_late_days == (student.late_days - days)
                    now = Time.now
                    update = Hash[]
                    if now < assignment.prepare_deadline
                      update[:prepare_deadline] = assignment.prepare_deadline + days * 86400
                    end
                    if now < assignment.approve_deadline
                      update[:approve_deadline] = assignment.approve_deadline + days * 86400
                    end
                    if (update_prepare != !update[:prepare_deadline].nil?) || (update_approve != !update[:approve_deadline].nil?)
                      @error = "A stale attempt to apply late days: either prepare or approve deadlines has happened already"
                      Hanami.logger.warn "A stale attempt to push deadlines for student #{student.id}" if Hanami.logger
                    else
                      @assignments.update(assignment.id, update)
                      @students.update(student.id, late_days: new_late_days)
                      redirect_to routes.student_path
                    end
                  else
                    @error = "Late days state is out of sync, reload main assignment list and try again"
                    Hanami.logger.warn "Mismatched expected new late days number for student #{student.id}: expected #{new_late_days}, actual #{student.late_days - days}" if Hanami.logger
                  end
                else
                  @error = "Applied late days number exceed range: #{days} vs [1..#{student.late_days}]"
                  Hanami.logger.warn @error if Hanami.logger
                end
              else
                @error = "Unknown student"
                Hanami.logger.warn "No such student: #{assignment.student_id}" if Hanami.logger
              end
            else
              @error = "Unknown assignment"
              Hanami.logger.warn "No such assignment: #{id}" if Hanami.logger
            end
          end
        end
      end
    end
  end
end

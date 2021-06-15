require 'csv'

module Admin
  module Controllers
    module Competitions
      class Create
        include Admin::Action

        def initialize(competition_repo: CompetitionRepository.new, assignment_repo: AssignmentRepository.new, student_repo: StudentRepository.new)
          @competition_repo = competition_repo
          @assignment_repo = assignment_repo
          @student_repo = student_repo
        end

        def call(params)
          if params[:competition]
            data = params[:competition]
            student_id = Integer(data[:student_id])
            homework_instance_id = Integer(data[:homework_instance_id])
            a = @assignment_repo.by_instance(student_id, homework_instance_id).first
            halt 404, "No such assignment" if a.nil?
            data[:data].split(/\r?\n/).each do |s|
              arr = s.split(' ')
              if arr.size != 2
                Hanami.logger.warn "Failed to parse competition score: #{s}"
                next
              end
              @competition_repo.create(assignment_id: a.id,
                                       score: Integer(arr[1]),
                                       name: arr[0])
            end
          elsif params[:bulk]
            data = params[:bulk]
            homework_instance_id = Integer(data[:homework_instance_id])
            table = CSV.parse(::File.read(data[:table][:tempfile]), headers: true)
            Hanami.logger.debug "#{table[0].headers.compact}"
            for j in 0..table.size-1 do
              for i in 0..table[j].headers.compact.size-1 do
                login = table[j][i*4]
                score = Integer(table[j][i*4+3] || 0)
                name = table[j].headers.compact[i]
                if score < 50
                  next
                end
                student = @student_repo.by_login(login)
                if student.nil?
                  Hanami.logger.warn "Not found a student #{login}"
                  next
                end
                a = @assignment_repo.by_instance(student.id, homework_instance_id).first
                if a.nil?
                  Hanami.logger.warn "No such assignment for student #{login} and instance #{homework_instance_id}"
                  next
                end
                c = @competition_repo.lookup(a.id, name).first
                if c.nil?
                  @competition_repo.create(assignment_id: a.id,
                                           score: score,
                                           name: name)
                else
                  @competition_repo.update(c.id,
                                           score: score)
                end
              end
            end
          end
          redirect_to routes.competitions_path
        end
      end
    end
  end
end

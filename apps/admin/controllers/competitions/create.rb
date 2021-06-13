module Admin
  module Controllers
    module Competitions
      class Create
        include Admin::Action

        def initialize(competition_repo: CompetitionRepository.new, assignment_repo: AssignmentRepository.new)
          @competition_repo = competition_repo
          @assignment_repo = assignment_repo
        end

        def call(params)
          data = params[:competition]
          student_id = Integer(data[:student_id])
          homework_instance_id = Integer(data[:homework_instance_id])
          a = @assignment_repo.by_instance(student_id, homework_instance_id)
          halt 404, "No such assignment" if a.nil?
          data[:data].split("\n").each do |s|
            arr = s.split(' ')
            if arr.size != 2
              Hanami.logger.warn "Failed to parse competition score: #{s}"
              next
            end
            @competition_repo.create(a.id, Integer(arr[1]), arr[0])
          end
          redirect_to routes.competitions_path
        end
      end
    end
  end
end

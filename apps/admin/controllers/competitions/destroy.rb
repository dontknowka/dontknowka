module Admin
  module Controllers
    module Competitions
      class Destroy
        include Admin::Action

        def initialize(competition_repo: CompetitionRepository.new)
          @competition_repo = competition_repo
        end

        def call(params)
          @competition_repo.delete_by_assignment(params[:id])
          redirect_to routes.competitions_path
        end
      end
    end
  end
end

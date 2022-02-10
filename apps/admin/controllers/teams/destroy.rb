module Admin
  module Controllers
    module Teams
      class Destroy
        include Admin::Action

        def initialize(team_repo: TeacherTeamRepository.new)
          @team_repo = team_repo
        end

        def call(params)
          @team_repo.delete(params[:id])
          redirect_to routes.teams_path
        end
      end
    end
  end
end

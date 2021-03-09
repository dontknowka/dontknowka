module Admin
  module Controllers
    module Teams
      class Index
        include Admin::Action

        expose :teams

        def initialize(team_repo: TeacherTeamRepository.new)
          @team_repo = team_repo
        end

        def call(params)
          @teams = @team_repo.all
        end
      end
    end
  end
end

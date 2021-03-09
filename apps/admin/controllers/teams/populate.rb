module Admin
  module Controllers
    module Teams
      class Populate
        include Admin::Action

        def initialize(populate_teams: PopulateTeams.new)
          @populate_teams = populate_teams
        end

        def call(params)
          @populate_teams.call
          redirect_to routes.teams_path
        end
      end
    end
  end
end

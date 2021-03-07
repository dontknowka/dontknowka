module Admin
  module Controllers
    module Home
      class AddTeamToRepos
        include Admin::Action

        def initialize(fetch_repos: FetchInstanceRepositories.new,
                       get_teams: GetTeams.new,
                       add_team_repo: AddTeamRepo.new,
                       protect_branch: ProtectBranch.new)
          @fetch_repos = fetch_repos
          @get_teams = get_teams
          @add_team_repo = add_team_repo
          @protect_branch = protect_branch
        end

        def call(params)
          data = params[:ta_mapping]
          if data.nil? || data[:homework].nil? || data[:team].nil?
            halt 404
          end
          team_id = Integer(data[:team])
          team = @get_teams.call.teams.detect {|t| t[:id] == team_id }
          if team.nil?
            halt 404
          end
          @fetch_repos.call(data[:homework]).repos.each do |repo|
            Hanami.logger.debug "Add team #{team[:name]} to #{repo[:name]}"
            @add_team_repo.call(team[:id], repo[:full_name])
            @protect_branch.call(repo[:full_name], [], [team[:slug]])
          end
          redirect_to routes.root_path
        end
      end
    end
  end
end

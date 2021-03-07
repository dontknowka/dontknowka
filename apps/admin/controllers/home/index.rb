module Admin
  module Controllers
    module Home
      class Index
        include Admin::Action

        expose :team_mapping

        def initialize(get_teams: GetTeams.new,
                       homework_instances: HomeworkInstanceRepository.new)
          @get_teams = get_teams
          @homework_instances = homework_instances
        end

        def call(params)
          @team_mapping = TeamMapping.new(@homework_instances.all, @get_teams.call.teams)
        end

        private

        class TeamMapping
          attr_reader :homeworks, :team_ids, :team_slugs

          def initialize(homeworks, teams)
            @homeworks = homeworks.reduce(Hash[]) {|h, w| h.merge({w.name => w.name}) }
            @team_ids = teams.reduce(Hash[]) {|h, t| h.merge({t[:name] => t[:id]})}
            @team_slugs = teams.reduce(Hash[]) {|h, t| h.merge({t[:name] => t[:slug]})}
          end
        end
      end
    end
  end
end

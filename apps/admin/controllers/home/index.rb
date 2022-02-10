module Admin
  module Controllers
    module Home
      class Index
        include Admin::Action

        expose :homeworks
        expose :team_mapping

        def initialize(get_teams: GetTeams.new,
                       homework_instances: HomeworkInstanceRepository.new)
          @get_teams = get_teams
          @homework_instances = homework_instances
        end

        def call(params)
          all_instances = @homework_instances.all
          @team_mapping = TeamMapping.new(all_instances, @get_teams.call.teams)
          @homeworks = all_instances.reduce(Hash[]) {|h, w| h.merge({w.name => w.id}) }
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

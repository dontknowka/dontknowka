module Admin
  module Controllers
    module TaMappings
      class Index
        include Admin::Action

        expose :mappings
        expose :instances
        expose :instance_name
        expose :teams

        def initialize(team_mapping_repo: TeamMappingRepository.new,
                       team_repo: TeacherTeamRepository.new,
                       instance_repo: HomeworkInstanceRepository.new)
          @team_mapping_repo = team_mapping_repo
          @team_repo = team_repo
          @instance_repo = instance_repo
        end

        def call(params)
          @mappings = @team_mapping_repo.with_teams
          instances = @instance_repo.all
          @instances = instances.reduce(Hash[]) {|h, i| h.merge({i.name => i.id})}
          @instance_name = instances.reduce(Hash[]) {|h, i| h.merge({i.id => i.name})}
          @teams = @team_repo.all.reduce(Hash[]) {|h, t| h.merge({t.name => t.id})}
        end
      end
    end
  end
end

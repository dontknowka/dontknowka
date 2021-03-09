module Admin
  module Controllers
    module TeamMappings
      class Index
        include Admin::Action

        expose :mappings
        expose :instances
        expose :teams
        expose :instance_name

        def initialize(mapping_repo: TeamMappingRepository.new,
                       team_repo: TeamRepository.new,
                       instance_repo: HomeworkInstanceRepository.new)
          @mapping_repo = mapping_repo
          @team_repo= team_repo
          @instance_repo = instance_repo
        end

        def call(params)
          instances = @instance_repo.all
          @instances = instances.map {|i| [i.name, i.id]}.to_h
          @instance_name = instances.map {|i| [i.id, i.name]}.to_h
          @teams = @team_repo.all.map {|t| [t.slug, t.id]}.to_h
          @mappings = @mapping_repo.with_teams
        end
      end
    end
  end
end

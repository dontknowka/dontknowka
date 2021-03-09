module Admin
  module Controllers
    module TeamMappings
      class Create
        include Admin::Action

        def initialize(mapping_repo: TeamMappingRepository.new)
          @mapping_repo = mapping_repo
        end

        def call(params)
          @mapping_repo.create(params[:mapping])
          redirect_to routes.team_mappings_path
        end
      end
    end
  end
end

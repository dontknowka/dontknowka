module Admin
  module Controllers
    module TeamMappings
      class Destroy
        include Admin::Action

        def initialize(mapping_repo: TeamMappingRepository.new)
          @mapping_repo = mapping_repo
        end

        def call(params)
          @mapping_repo.delete(params[:id])
          redirect_to routes.team_mappings_path
        end
      end
    end
  end
end

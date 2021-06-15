module Admin
  module Controllers
    module TaMappings
      class Destroy
        include Admin::Action

        def initialize(team_mapping_repo: TeamMappingRepository.new)
          @team_mapping_repo = team_mapping_repo
        end

        def call(params)
          @team_mapping_repo.delete(params[:id])
          redirect_to routes.ta_mappings_path
        end
      end
    end
  end
end

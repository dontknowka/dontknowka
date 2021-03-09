module Admin
  module Controllers
    module TaMappings
      class Update
        include Admin::Action

        def initialize(sets: TeamMappingRepository.new)
          @team_mapping_repo = team_mapping_repo
        end

        def call(params)
          @team_mapping_repo.update(params[:id], params[:tm])
          redirect_to routes.ta_mappings_path
        end
      end
    end
  end
end

module Admin
  module Controllers
    module TaMappings
      class Create
        include Admin::Action

        def initialize(team_mapping_repo: TeamMappingRepository.new)
          @team_mapping_repo = team_mapping_repo
        end

        def call(params)
          @team_mapping_repo.create(params[:tm])
          redirect_to routes.ta_mappings_path
        end
      end
    end
  end
end

module Admin
  module Controllers
    module TaMappings
      class Update
        include Admin::Action

        def initialize(sets: TeacherMappingRepository.new)
          @tms = tms
        end

        def call(params)
          @tms.update(params[:id], params[:tm])
          redirect_to routes.ta_mappings_path
        end
      end
    end
  end
end

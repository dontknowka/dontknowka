module Admin
  module Controllers
    module TaMappings
      class Create
        include Admin::Action

        def initialize(tms: TeacherMappingRepository.new)
          @tms = tms
        end

        def call(params)
          @tms.create(params[:tm])
          redirect_to routes.ta_mappings_path
        end
      end
    end
  end
end

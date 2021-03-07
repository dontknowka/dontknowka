module Admin
  module Controllers
    module TaMappings
      class Destroy
        include Admin::Action

        def initialize(tms: TeacherMappingRepository.new)
          @tms = tms
        end

        def call(params)
          @tms.delete(params[:id])
          redirect_to routes.ta_mappings_path
        end
      end
    end
  end
end

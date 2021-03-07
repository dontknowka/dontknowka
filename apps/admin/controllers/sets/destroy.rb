module Admin
  module Controllers
    module Sets
      class Destroy
        include Admin::Action

        def initialize(sets: HomeworkSetRepository.new)
          @sets = sets
        end

        def call(params)
          @sets.delete(params[:id])
          redirect_to routes.sets_path
        end
      end
    end
  end
end

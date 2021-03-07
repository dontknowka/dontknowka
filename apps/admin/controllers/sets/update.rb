module Admin
  module Controllers
    module Sets
      class Update
        include Admin::Action

        def initialize(sets: HomeworkSetRepository.new)
          @sets = sets
        end

        def call(params)
          @sets.update(params[:id], params[:set])
          redirect_to routes.sets_path
        end
      end
    end
  end
end

module Admin
  module Controllers
    module Homeworks
      class Destroy
        include Admin::Action

        def initialize(homeworks: HomeworkRepository.new)
          @homeworks = homeworks
        end

        def call(params)
          @homeworks.delete(params[:id])
          redirect_to routes.homeworks_path
        end
      end
    end
  end
end

module Admin
  module Controllers
    module Homeworks
      class Create
        include Admin::Action

        def initialize(homeworks: HomeworkRepository.new)
          @homeworks = homeworks
        end

        def call(params)
          @homeworks.create(params[:homework])
          redirect_to routes.homeworks_path
        end
      end
    end
  end
end

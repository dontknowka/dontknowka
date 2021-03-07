module Admin
  module Controllers
    module Homeworks
      class Index
        include Admin::Action

        expose :homeworks

        def initialize(homeworks: HomeworkRepository.new)
          @homework_repo = homeworks
        end

        def call(params)
          @homeworks = @homework_repo.all
        end
      end
    end
  end
end

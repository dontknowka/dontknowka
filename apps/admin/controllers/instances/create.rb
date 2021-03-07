module Admin
  module Controllers
    module Instances
      class Create
        include Admin::Action

        def initialize(instances: HomeworkInstanceRepository.new)
          @instances = instances
        end

        def call(params)
          @instances.create(params[:instance])
          redirect_to routes.instances_path
        end
      end
    end
  end
end

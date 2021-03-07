module Admin
  module Controllers
    module Instances
      class Update
        include Admin::Action

        def initialize(instances: HomeworkInstanceRepository.new)
          @instances = instances
        end

        def call(params)
          @instances.update(params[:id], params[:instance])
          redirect_to routes.instances_path
        end
      end
    end
  end
end

module Admin
  module Controllers
    module Instances
      class Destroy
        include Admin::Action

        def initialize(instances: HomeworkInstanceRepository.new)
          @instances = instances
        end

        def call(params)
          @instances.delete(params[:id])
          redirect_to routes.instances_path
        end
      end
    end
  end
end

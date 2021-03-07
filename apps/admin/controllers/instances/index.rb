module Admin
  module Controllers
    module Instances
      class Index
        include Admin::Action

        expose :instances
        expose :hw_mapping
        expose :hw_rmapping

        def initialize(instances: HomeworkInstanceRepository.new, homeworks: HomeworkRepository.new)
          @instance_repo = instances
          @homework_repo = homeworks
        end

        def call(params)
          @instances = @instance_repo.all
          homeworks = @homework_repo.all
          @hw_mapping = homeworks.map {|hw| [hw.kind + hw.number.to_s, hw.id]}.to_h
          @hw_rmapping = homeworks.map {|hw| [hw.id, hw.kind + hw.number.to_s]}.to_h
        end
      end
    end
  end
end

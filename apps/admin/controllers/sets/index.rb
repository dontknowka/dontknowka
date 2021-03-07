module Admin
  module Controllers
    module Sets
      class Index
        include Admin::Action

        expose :sets
        expose :i_mapping
        expose :i_rmapping

        def initialize(sets: HomeworkSetRepository.new, instances: HomeworkInstanceRepository.new)
          @set_repo = sets
          @instance_repo = instances
        end

        def call(params)
          @sets = @set_repo.all
          instances = @instance_repo.all
          @i_mapping = instances.map {|i| [i.name, i.id]}.to_h
          @i_rmapping = instances.map {|i| [i.id, i.name]}.to_h
        end
      end
    end
  end
end

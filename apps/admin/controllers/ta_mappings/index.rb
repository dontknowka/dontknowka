module Admin
  module Controllers
    module TaMappings
      class Index
        include Admin::Action

        expose :tms
        expose :i_mapping
        expose :i_rmapping
        expose :teacher_mapping

        def initialize(tms: TeacherMappingRepository.new,
                       teachers: TeacherRepository.new,
                       instances: HomeworkInstanceRepository.new)
          @tm_repo = tms
          @teacher_repo = teachers
          @instance_repo = instances
        end

        def call(params)
          @tms = @tm_repo.with_teachers
          instances = @instance_repo.all
          @i_mapping = instances.map {|i| [i.name, i.id]}.to_h
          @i_rmapping = instances.map {|i| [i.id, i.name]}.to_h
          teachers = @teacher_repo.all
          @teacher_mapping = teachers.map {|t| [t.login, t.id]}.to_h
        end
      end
    end
  end
end

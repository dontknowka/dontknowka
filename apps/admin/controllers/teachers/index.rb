module Admin
  module Controllers
    module Teachers
      class Index
        include Admin::Action

        expose :teachers

        def initialize(teacher_repo: TeacherRepository.new)
          @teacher_repo = teacher_repo
        end

        def call(params)
          @teachers = @teacher_repo.teachers_with_teams
        end
      end
    end
  end
end

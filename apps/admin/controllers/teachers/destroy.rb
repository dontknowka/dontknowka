module Admin
  module Controllers
    module Teachers
      class Destroy
        include Admin::Action

        def initialize(teacher_repo: TeacherRepository.new)
          @teacher_repo = teacher_repo
        end

        def call(params)
          @teacher_repo.delete(params[:id])
          redirect_to routes.teachers_path
        end
      end
    end
  end
end

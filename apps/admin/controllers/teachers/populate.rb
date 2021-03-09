module Admin
  module Controllers
    module Teachers
      class Populate
        include Admin::Action

        def initialize(populate_teachers: PopulateTeachers.new)
          @populate_teachers = populate_teachers
        end

        def call(params)
          @populate_teachers.call
          redirect_to routes.teachers_path
        end
      end
    end
  end
end

module Admin
  module Controllers
    module TeacherMappings
      class Destroy
        include Admin::Action

        def call(params)
          self.body = 'OK'
        end
      end
    end
  end
end

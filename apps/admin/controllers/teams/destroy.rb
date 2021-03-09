module Admin
  module Controllers
    module Teams
      class Destroy
        include Admin::Action

        def call(params)
          self.body = 'OK'
        end
      end
    end
  end
end

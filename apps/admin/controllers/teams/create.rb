module Admin
  module Controllers
    module Teams
      class Create
        include Admin::Action

        def call(params)
          self.body = 'OK'
        end
      end
    end
  end
end

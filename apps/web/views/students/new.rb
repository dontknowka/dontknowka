module Web
  module Views
    module Students
      class New
        include Web::View
        layout false

        def form
          form_for :passcode, routes.new_student_auth_path do
            password_field :value, class: 'form-control'
            submit 'Send', class: 'btn btn-primary'
          end
        end
      end
    end
  end
end

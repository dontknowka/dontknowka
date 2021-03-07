module Web
  module Views
    module Students
      class Profile
        include Web::View

        def form
          form_for :student, routes.student_profile_path, values: { student: student } do
            div class: 'form-group' do
              div class: 'form-group-header' do
                label :first_name
              end
              div class: 'form-group-body' do
                text_field :first_name, class: 'form-control'
              end
            end
            div class: 'form-group' do
              div class: 'form-group-header' do
                label :last_name
              end
              div class: 'form-group-body' do
                text_field :last_name, class: 'form-control'
              end
            end
            div class: 'form-group' do
              div class: 'form-group-header' do
                label :email
              end
              div class: 'form-group-body' do
                email_field :email, class: 'form-control'
              end
            end
            div class: 'form-group' do
              div class: 'form-group-header' do
                label :group
              end
              div class: 'form-group-body' do
                text_field :group, class: 'form-control'
              end
            end
            submit 'Save', class: 'btn btn-primary'
            a class: 'btn', role: 'button', href: routes.student_path do
              "Back"
            end
          end
        end
      end
    end
  end
end

module Web
  module Controllers
    module Teacher
      module CheckRole
        def self.included(action)
          action.class_eval do
            before :check_role
          end
        end

        private

        def check_role
          if session[:role] != 'teacher'
            redirect_to routes.root_path
          end
          @teacher = @teachers.find(session[:github_id])
          if @teacher.nil?
            if @check_membership.call(session[:login]).result
              redirect_to routes.teacher_profile_path
            else
              halt 403, "You need to be a member of TA team"
            end
          end
        end
      end
    end
  end
end

module Web
  module Controllers
    module Students
      class NewAuth
        include Web::Action

        def initialize(passcode: ENV['ORG_PASSCODE'], invite_user: InviteUser.new(team_id: ENV['STUDENT_TEAM_ID']))
          @passcode = passcode
          @invite_user = invite_user
        end

        def call(params)
          if params[:passcode][:value] != @passcode
            halt 403
          end
          result = @invite_user.call(session[:github_id])
          Hanami.logger.debug "Invite sent: #{result.valid}"
          redirect_to routes.student_profile_path
        end
      end
    end
  end
end

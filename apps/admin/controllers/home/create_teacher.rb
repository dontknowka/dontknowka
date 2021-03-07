module Admin
  module Controllers
    module Home
      class CreateTeacher
        include Admin::Action

        def initialize(teachers: TeacherRepository.new,
                       get_teams: GetTeams.new)
          @teachers = teachers
          @get_teams = get_teams
        end

        def call(params)
          data = params[:ta_mapping]
          if data.nil? || data[:team].nil?
            halt 404
          end
          team_id = Integer(data[:team])
          team = @get_teams.call.teams.detect {|t| t[:id] == team_id }
          if team.nil?
            halt 404
          end
          teacher = @teachers.find(team_id)
          if teacher.nil?
            @teachers.create({ id: team_id,
                               login: team[:slug],
                               first_name: team[:name],
                               last_name: 'Team',
                               email: 'foo@example.com' })
          else
            Hanami.logger.debug "Teacher already exists"
          end
          redirect_to routes.root_path
        end
      end
    end
  end
end

module Web
  module Controllers
    module Teacher
      class Assignments
        include Web::Action

        before :authenticate?

        expose :login
        expose :avatar

        expose :not_approved

        def initialize(fetch_pull_requests: FetchPullRequests.new,
                       check_membership: CheckMembership.new,
                       teachers: TeacherRepository.new,
                       teacher_mappings: TeacherMappingRepository.new,
                       assignments: AssignmentRepository.new)
          @fetch_pull_requests = fetch_pull_requests
          @check_membership = check_membership
          @teachers = teachers
          @teacher_mappings = teacher_mappings
          @assignments = assignments
        end

        def call(params)
          if session[:role] != 'teacher'
            redirect_to routes.root_path
          end
          teacher = @teachers.find(session[:github_id])
          if teacher.nil?
            if @check_membership.call(session[:login]).result
              redirect_to routes.teacher_profile_path
            else
              halt 403, "You need to be a member of TA team"
            end
          end
          @login = session[:login]
          @avatar = session[:avatar]

          instances = @teacher_mappings.by_teacher(teacher.id).map {|tm| tm.homework_instance_id}
          @not_approved = @assignments
            .not_approved(instances)
            .map {|a| Assignment.new(a.merge({url: last_pr_url(a[:repo])}))}
        end

        private

        def authenticate?
          authenticate! if session[:github_id].nil?
        end

        def authenticate!
          redirect_to routes.login_path
        end

        def last_pr_url(repo)
          pulls = @fetch_pull_requests.call(repo, 'open').pulls
          pulls[0][:html_url] unless pulls[0].nil?
        end

        class Assignment
          attr_reader :name, :status, :status_style, :deadline, :deadline_style, :login, :url, :repo_url, :updated_at

          def initialize(data)
            @name = data[:name]
            @status = (data[:status] || '').capitalize.gsub('_', ' ')
            @status_style = case @status
                            when 'ready'
                              'Label--pink'
                            when 'in_progress'
                              'Label--yellow'
                            when 'failed'
                              'Label--red'
                            end
            @deadline = ((data[:approve_deadline] - Time.now) / 86400).to_i
            if @deadline < 0
              @deadline = 0
            end
            @deadline_style = case @deadline
                              when proc {|n| n < 2}
                                'text-red'
                              when proc {|n| n < 5}
                                'text-orange'
                              else
                                'text-green'
                              end
            @login = data[:login]
            @url = data[:url]
            @repo_url = data[:repo_url]
            @updated_at = data[:updated_at]
          end
        end
      end
    end
  end
end

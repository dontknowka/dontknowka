require_relative './check_role'

module Web
  module Controllers
    module Teacher
      class Assignments
        include Web::Action
        include CheckRole

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
          @login = session[:login]
          @avatar = session[:avatar]

          instances = @teacher_mappings.by_teacher(@teacher.id).map {|tm| tm.homework_instance_id}
          @not_approved = @assignments
            .not_approved(instances)
            .map {|a| Assignment.new(a.merge({url: last_pr_url(a[:repo])}))}
        end

        private

        def last_pr_url(repo)
          pulls = @fetch_pull_requests.call(repo, 'open').pulls
          pulls[0][:html_url] unless pulls[0].nil?
        end

        class Assignment
          attr_reader :name, :status, :status_style, :prepare_deadline, :approve_deadline, :days_left, :days_left_style, :login, :url, :repo_url, :updated_at

          def initialize(data)
            @name = data[:name]
            status = (data[:status] || '')
            @status = status.capitalize.gsub('_', ' ')
            @status_style = case status
                            when 'ready'
                              'Label--pink'
                            when 'in_progress'
                              'Label--yellow'
                            when 'failed'
                              'Label--red'
                            end
            approve_deadline = data[:approve_deadline] || (Time.now - 86400 * 100)
            @days_left = ((approve_deadline - Time.now) / 86400).to_i
            if @days_left < 0
              @days_left = 0
            end
            @days_left_style = case @days_left
                              when proc {|n| n < 2}
                                'text-red'
                              when proc {|n| n < 5}
                                'text-orange'
                              else
                                'text-green'
                              end
            @approve_deadline = approve_deadline.strftime("%d.%m.%Y %H:%M:%S")
            @prepare_deadline = ''
            if data[:prepare_deadline]
              @prepare_deadline = data[:prepare_deadline].strftime("%d.%m.%Y %H:%M:%S")
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

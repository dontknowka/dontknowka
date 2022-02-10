require 'date'
require_relative './check_role'

module Web
  module Controllers
    module Teacher
      class Home
        include Web::Action
        include CheckRole

        expose :login
        expose :avatar

        expose :awaiting
        expose :updated
        expose :expired
        expose :failed

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
          @teachers.update(@teacher.id,
                           login: session[:login],
                           avatar: session[:avatar])
          @login = session[:login]
          @avatar = session[:avatar]

          instances = @teacher_mappings.by_teacher(@teacher.id).map {|tm| tm.homework_instance_id}
          @awaiting = @assignments
            .awaiting_reviews(instances)
            .map {|a| Assignment.new(a.merge({url: last_pr_url(a[:repo])}))}
          @updated = @assignments
            .updated_after_review(instances)
            .map {|a| Assignment.new(a.merge({url: last_pr_url(a[:repo])}))}
          @expired = @assignments
            .expired(instances, Time.now)
            .map {|a| Assignment.new(a.merge({url: last_pr_url(a[:repo])}))}
          @failed = @assignments
            .failed(instances)
            .map {|a| Assignment.new(a.merge({url: last_pr_url(a[:repo])}))}
        end

        private

        def last_pr_url(repo)
          pulls = @fetch_pull_requests.call(repo, 'open').pulls
          pulls[0][:html_url] unless pulls[0].nil?
        end

        class Assignment
          attr_reader :name, :deadline, :days_left, :days_left_style, :login, :url, :repo_url, :updated_at

          def initialize(data)
            @name = data[:name]
            deadline = data[:approve_deadline] || Time.now
            @days_left = ((deadline - Time.now) / 86400).to_i
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
            @deadline = deadline.strftime("%d.%m.%Y %H:%M:%S")
            @login = data[:login]
            @url = data[:url]
            @repo_url = data[:repo_url]
            if !data[:updated_at].nil?
              @updated_at = (data[:updated_at].is_a?(Time) ? data[:updated_at] : Time.parse(data[:updated_at])).strftime("%d.%m.%Y %H:%M:%S")
            end
          end
        end
      end
    end
  end
end

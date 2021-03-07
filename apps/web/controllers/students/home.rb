module Web
  module Controllers
    module Students
      class Home
        include Web::Action

        before :authenticate?

        expose :student
        expose :avatar
        expose :home
        expose :profile
        expose :homeworks

        def initialize(check_membership: CheckMembership.new(org: ENV['GITHUB_ORG']),
                       students: StudentRepository.new,
                       assignments: AssignmentRepository.new,
                       homework_sets: HomeworkSetRepository.new)
          @check_membership = check_membership
          @students = students
          @assignments = assignments
          @homework_sets = homework_sets
        end

        def call(params)
          if session[:role] != 'student'
            redirect_to routes.root_path
          end
          student = @students.find(session[:github_id])
          if student.nil?
            if @check_membership.call(session[:login]).result
              redirect_to routes.student_profile_path
            else
              redirect_to routes.new_student_auth_path
            end
          end
          @student = @students.update(student.id,
                           login: session[:login],
                           avatar: session[:avatar])
          @avatar = @student.avatar
          @profile = routes.student_profile_path
          @home = routes.student_path

          set_names = @homework_sets.all_set_names
          ass = @assignments.with_sets(@student)
          @homeworks = set_names.flat_map do |set|
            a = ass.detect { |a| a[:homework_set_name] == set }
            if a.nil?
              Homework.new(homework_set_name: set)
            else
              Homework.new(a)
            end
          end
        end

        private

        def authenticate?
          authenticate! if session[:github_id].nil?
        end

        def authenticate!
          redirect_to routes.login_path
        end

        class Homework
          attr_reader :set, :type, :name, :status, :colour, :url, :url_title, :worth, :prepare_before, :approve_before

          def initialize(options)
            @set = options[:homework_set_name]
            @type = options[:homework_kind] + options[:homework_number].to_s if !options[:homework_kind].nil?
            @name = options[:homework_instance_name]
            @status = (options[:status] || '').capitalize.gsub('_', ' ')
            @colour = case options[:status]
                      when 'in_progress'
                        'yellow'
                      when 'ready'
                        'pink'
                      when 'approved'
                        'green'
                      when 'failed'
                        'red'
                      end
            if options[:url].nil? || options[:url].empty?
              @url = options[:classroom_url]
              @url_title = 'Activate'
            else
              @url = options[:url]
              @url_title = 'Go to repo'
            end
            @worth = options[:worth]
            if !options[:prepare_deadline].nil?
              @prepare_before = options[:prepare_deadline].strftime("%d.%m.%Y %H:%M:%S")
              @approve_before = options[:approve_deadline].strftime("%d.%m.%Y %H:%M:%S")
            end
          end
        end
      end
    end
  end
end

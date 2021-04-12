require 'ostruct'

module Web
  module Controllers
    module Set
      class Choose
        include Web::Action

        before :authenticate?

        expose :classroom_url

        def initialize(round_robin: RoundRobin.new,
                       homeworks: HomeworkRepository.new,
                       homework_sets: HomeworkSetRepository.new,
                       assignments: AssignmentRepository.new)
          @round_robin = round_robin
          @homeworks = homeworks
          @homework_sets = homework_sets
          @assignments = assignments
        end

        def call(params)
          name = params[:set][:name] || ''
          halt 404 if name.empty?
          variants = @homework_sets.get_variants(name)
          halt 404 if variants.empty?
          n = @round_robin.call("assignment:#{name}", variants.length).value
          variants[n-1].each do |chosen|
            ass = @assignments.by_instance(session[:github_id], chosen[:homework_instance_id])
            if ass.empty?
              @assignments.create(student_id: session[:github_id],
                                  homework_instance_id: chosen[:homework_instance_id],
                                  prepare_deadline: chosen[:prepare_deadline],
                                  approve_deadline: chosen[:approve_deadline],
                                  url: '',
                                  repo: "#{chosen[:homework_instance_name].strip}-#{session[:login]}")
            end
          end
          redirect_to routes.student_path
        end

        private

        def authenticate?
          authenticate! if session[:github_id].nil?
        end

        def authenticate!
          redirect_to routes.login_path
        end
      end
    end
  end
end

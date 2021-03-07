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
          instances = @homework_sets.get_instances(name)
          halt 404 if instances.empty?
          n = @round_robin.call("assignment:#{name}", instances.length).value
          chosen = instances[n-1]
          Hanami.logger.debug "Activating #{chosen.homework_instance.name} at #{chosen.homework_instance.classroom_url}"
          ass = @assignments.by_instance(session[:github_id], chosen.homework_instance.id)
          if ass.empty?
            hw = @homeworks.find(chosen.homework_instance.homework_id)
            halt 404 if hw.nil?
            @assignments.create({ student_id: session[:github_id],
                                  homework_instance_id: chosen.homework_instance.id,
                                  prepare_deadline: hw.prepare_deadline,
                                  approve_deadline: hw.approve_deadline,
                                  url: '',
                                  repo: "#{chosen.homework_instance.name.strip}-#{session[:login]}" })
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

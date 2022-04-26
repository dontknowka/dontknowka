module Admin
  module Controllers
    module Home
      class CreateVariants
        include Admin::Action

        def initialize(homework_sets: HomeworkSetRepository.new,
                       assignments: AssignmentRepository.new)
          @homework_sets = homework_sets
          @assignments = assignments
        end

        def call(params)
          variants = @homework_sets.all_variants
          assignments = @assignments.group_by_student
          assignments.each_key do |student_id|
            existing = assignments[student_id].map {|a| a[:homework_instance_id]}
            assignments[student_id].each do |a|
              variants.each do |var|
                if var.instances.any? a[:homework_instance_id]
                  var.homeworks.each do |hw|
                    if existing.none? hw[:id]
                      Hanami.logger.debug "No assignment #{hw[:homework_instance_name]} for variant #{var.variant_id} and student #{a[:login]}, creating" if Hanami.logger
                      @assignments.create(student_id: student_id,
                                          homework_instance_id: hw[:id],
                                          prepare_deadline: hw[:prepare_deadline],
                                          approve_deadline: hw[:approve_deadline],
                                          url: '',
                                          repo: "#{hw[:homework_instance_name].strip}-#{a[:login]}")
                    end
                  end
                end
              end
            end
          end
          redirect_to routes.root_path
        end
      end
    end
  end
end

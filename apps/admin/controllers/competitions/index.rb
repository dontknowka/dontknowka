module Admin
  module Controllers
    module Competitions
      class Index
        include Admin::Action

        expose :competitions
        expose :students
        expose :i_mapping
        expose :i_rmapping

        def initialize(competition_repo: CompetitionRepository.new,
                       student_repo: StudentRepository.new,
                       instance_repo: HomeworkInstanceRepository.new)
          @competition_repo = competition_repo
          @student_repo = student_repo
          @instance_repo = instance_repo
        end

        def call(params)
          @competitions = @competition_repo
            .with_students
            .group_by {|obj| obj[:assignment_id]}
            .map {|id, items| CompetitionInfo.new(id, items)}
          @students = @student_repo
            .all
            .reduce(Hash[]) {|h, s| h.merge({s.login => s.id})}
            .sort {|a, b| a[0] <=> b[0]}
          instances = @instance_repo.all
          @i_mapping = instances.map {|i| [i.name, i.id]}.to_h
          @i_rmapping = instances.map {|i| [i.id, i.name]}.to_h
        end

        private

        class StudentInfo
          attr_reader :id, :name

          def initialize(student)
            @id = student.id
            @name = (student.first_name || '') + ' ' + (student.last_name || '')
            if @name.empty?
              @name = student.login
            end
          end
        end

        class CompetitionInfo
          attr_reader :assignment_id, :student_name, :homework_instance_id, :scores

          def initialize(id, items)
            @assignment_id = id
            @student_name = items.first[:login]
            @homework_instance_id = items.first[:homework_instance_id]
            @scores = items.map {|o| o[:score]}
          end
        end
      end
    end
  end
end

module Admin
  module Controllers
    module Bonuses
      class Index
        include Admin::Action

        expose :bonuses
        expose :students

        def initialize(bonus_repo: BonusRepository.new,
                       student_repo: StudentRepository.new)
          @bonus_repo = bonus_repo
          @student_repo = student_repo
        end

        def call(params)
          @bonuses = @bonus_repo
            .with_students
            .map {|x| BonusInfo.new(x)}
          @students = @student_repo
            .all
            .map {|x| StudentInfo.new(x)}
            .reduce(Hash[]) {|h, s| h.merge({s.name => s.id})}
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

        class BonusInfo
          attr_reader :id, :student_name, :worth, :why

          def initialize(bonus)
            @id = bonus.id
            @student_name = StudentInfo.new(bonus.student).name
            @worth = bonus.worth
            @why = bonus.why
          end
        end
      end
    end
  end
end

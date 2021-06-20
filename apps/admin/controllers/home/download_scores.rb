require 'csv'

module Admin
  module Controllers
    module Home
      class DownloadScores
        include Admin::Action

        def initialize(student_repo: StudentRepository.new,
                       get_student_score: GetStudentScore.new)
          @student_repo = student_repo
          @get_student_score = get_student_score
        end

        def call(params)
          scores = @student_repo.ordered.map {|s| StudentInfo.new(s, @get_student_score.call(s).total)}

          self.format = :csv
          self.headers.merge!({ 'Content-Disposition' => 'attachment; filename="scores.csv"' })
          self.body = CSV.generate('', encoding: 'utf8', write_headers: true, headers: ['Group', 'First name', 'Last name', 'Login', 'Score']) do |csv|
            scores.each {|s| csv << [s.group, s.first_name, s.last_name, s.login, s.score]}
          end
        end

        private

        class StudentInfo
          attr_reader :login, :first_name, :last_name, :group, :score

          def initialize(data, score)
            @login = data.login
            @first_name = data.first_name
            @last_name = data.last_name
            @group = data.group
            @score = score
          end
        end
      end
    end
  end
end

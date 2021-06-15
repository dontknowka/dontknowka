require 'hanami/interactor'

class GetStudentScore
  include Hanami::Interactor

  expose :total
  expose :bonuses
  expose :assignments

  def initialize(assignment_repo: AssignmentRepository.new,
                 bonus_repo: BonusRepository.new)
    @assignment_repo = assignment_repo
    @bonus_repo = bonus_repo
  end

  def call(student)
    @assignments = @assignment_repo
      .with_reviews(student)
      .filter {|a| a.status == 'approved'}
      .map {|a| AssignmentScore.new(a)}
    @bonuses = @bonus_repo.by_student(student)
    @total = @bonuses.reduce(0) {|acc, b| acc + b.worth} + @assignments.reduce(0) {|acc, a| acc + a.score}
  end

  private

  class AssignmentScore
    attr_reader :worth, :url, :name, :status, :colour, :check_runs, :check_malus, :reviews, :review_malus, :interview_malus, :total_malus, :bench_bonus, :score

    def initialize(a)
      @worth = a.homework_instance.worth
      @url = a.url
      @name = a.homework_instance.name
      @status = (a.status || '').capitalize.gsub('_', ' ')
      @colour = case a.status
                when 'in_progress'
                  'yellow'
                when 'ready'
                  'pink'
                when 'approved'
                  'green'
                when 'failed'
                  'red'
                end
      @check_runs = a.check_runs.size
      @check_malus = @check_runs / 15
      @reviews = a.reviews.sort_by {|r| r.submitted_at}
      @review_malus = @reviews.size + @reviews.drop(1).reduce(0) {|acc, r| acc + [r.number_of_criticism - 1, 0].max}
      @interview_malus = 0
      if a.interview
        @interview_malus = a.interview.malus
      end
      @total_malus = @check_malus + @review_malus - @interview_malus
      @score = @worth > @total_malus ? @worth - @total_malus : 0
      competition_worth = [@worth, 25].min
      competition_score = competition_worth > @total_malus ? competition_worth - @total_malus : 0
      @bench_bonus = 0
      if a.competitions && a.competitions.size > 0
        part = [(competition_score * 1.0) / a.competitions.size, 1.0].max
        bonus = a.competitions.reduce(0) do |acc, c|
          acc += case c.score
                 when 95
                   part * 2
                 when 90
                   part * 1.5
                 when 85
                   part
                 when 80
                   part * 0.7
                 when 75
                   part * 0.5
                 when 70
                   part * 0.3
                 when 65
                   part * 0.1
                 else
                   0
                 end
        end
        @bench_bonus = Integer(bonus)
      end
      @score += @bench_bonus
    end
  end
end

require 'hanami/interactor'

class ReviewCreator
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(assignments: AssignmentRepository.new,
                 reviews: ReviewRepository.new)
    @assignments = assignments
    @reviews = reviews
  end

  def call(id, teacher_id, repo, pull, submitted_at, text, url)
    ass = @assignments.by_repo(repo)
    case ass.size
    when 0
      @success = false
      @comment = 'No associated assignment'
    when 1
      a = ass[0]
      if a.status != 'approved' && a.status != 'failed'
        n = text
          .lines
          .map(&:strip)
          .count {|x| x.start_with? '- [ ] ', '- [] '}
        @reviews.create({ id: id,
                          assignment_id: a.id,
                          teacher_id: teacher_id,
                          pull: pull,
                          submitted_at: submitted_at,
                          number_of_criticism: n,
                          url: url })
        @success = true
        @comment = ''
      else
        @success = true
        @comment = 'Not relevant for this assignment status'
      end
    else
      @success = false
      @comment = 'Several matching assignments'
    end
  end
end

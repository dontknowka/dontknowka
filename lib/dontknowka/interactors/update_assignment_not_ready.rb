require 'hanami/interactor'

class UpdateAssignmentNotReady
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(assignments: AssignmentRepository.new)
    @assignments = assignments
  end

  def call(repo)
    ass = @assignments.by_repo(repo)
    case ass.size
    when 0
      @success = false
      @comment = 'No associated assignment'
    when 1
      a = ass[0]
      if a.status == 'approved'
        @success = true
        @comment = 'Already approved'
      else
        now = Time.now
        if now < a.approve_deadline
          @assignments.update(a.id, status: 'in_progress')
          @success = true
          @comment = ''
        else
          @assignments.update(a.id, status: 'failed')
          @success = true
          @comment = ''
        end
      end
    else
      @success = false
      @comment = 'Several matching assignments'
    end
  end
end

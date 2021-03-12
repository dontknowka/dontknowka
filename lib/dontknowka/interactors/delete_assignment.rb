require 'hanami/interactor'

class DeleteAssignment
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
      @assignments.delete(ass[0].id)
      @success = true
      @comment = ''
    else
      @success = false
      @comment = 'Several matching assignments'
    end
  end
end

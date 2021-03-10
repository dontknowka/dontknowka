require 'hanami/interactor'

class UpdateAssignmentApprove
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(assignments: AssignmentRepository.new)
    @assignments = assignments
    @transitions = { 'in_progress' => 'approved', 'ready' => 'approved' }
  end

  def call(repo)
    ass = @assignments.by_repo(repo)
    case ass.size
    when 0
      @success = false
      @comment = 'No associated assignment'
    when 1
      a = ass[0]
      new_status = @transitions[a.status]
      if new_status.nil?
        @success = false
        @comment = "Unexpected assignment stage '#{a.status}' for being approved"
      else
        @assignments.update(a.id, status: new_status)
        @success = true
        @comment = ''
      end
    else
      @success = false
      @comment = 'Several matching assignments'
    end
  end
end

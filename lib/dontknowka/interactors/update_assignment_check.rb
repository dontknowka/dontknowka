require 'hanami/interactor'

class UpdateAssignmentCheck
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(assignments: AssignmentRepository.new)
    @assignments = assignments
    @good_trans = { 'open' => 'ready', 'in_progress' => 'ready' }
    @bad_trans = { 'ready' => 'in_progress', 'reviewed' => 'in_progress' }
  end

  def call(repo, conclusion)
    ass = @assignments.by_repo(repo)
    case ass.size
    when 0
      @success = false
      @comment = 'No associated assignment'
    when 1
      a = ass[0]
      update = { }
      if a.status != 'approved'
        update[:check_runs] = a.check_runs + 1
      end
      new_status = case conclusion
                   when 'success'
                     @good_trans[a.status]
                   when 'failure'
                     @bad_trans[a.status]
                   end
      if new_status.nil?
        @comment = "No '#{conclusion}' transition from '#{a.status}'"
      else
        update[:status] = new_status
        @comment = ''
      end
      @assignments.update(a.id, update)
      @success = true
    else
      @success = false
      @comment = 'Several matching assignments'
    end
  end
end

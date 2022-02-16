require 'hanami/interactor'

class UpdateAssignmentCheck
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(assignments: AssignmentRepository.new,
                 check_runs: CheckRunRepository.new)
    @assignments = assignments
    @check_runs = check_runs
    @good_trans = { 'open' => 'ready', 'in_progress' => 'ready' }
    @bad_trans = { 'ready' => 'in_progress', 'reviewed' => 'in_progress' }
  end

  def call(repo, pull, conclusion, id, url, completed_at)
    ass = @assignments.by_repo(repo)
    case ass.size
    when 0
      @success = false
      @comment = 'No associated assignment'
    when 1
      a = ass[0]
      if a.status != 'approved'
        cr = @check_runs.find(id)
        if cr.nil?
          @check_runs.create(id: id, assignment_id: a.id, url: url, completed_at: completed_at, pull: pull)
        else
          Hanami.logger.debug "Already processed #{id} check run" if Hanami.logger
          @success = true
          @comment = 'Already processed that check run'
          return
        end
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
        @assignments.update(a.id, status: new_status)
        @comment = ''
      end
      @success = true
    else
      @success = false
      @comment = 'Several matching assignments'
    end
  end
end

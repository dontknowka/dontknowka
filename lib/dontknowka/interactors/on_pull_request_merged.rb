require 'hanami/interactor'

class OnPullRequestMerged
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(assignments: AssignmentRepository.new)
    @assignments = assignments
  end

  def call(payload)
    repo = payload[:repository]
    ass = @assignments.by_repo(repo[:name])
    case ass.size
    when 0
      @success = false
      @comment = 'No such assignment'
    when 1
      a = ass[0]
      if a.status == 'ready' || a.status == 'in_progress'
        @assignments.update(a.id, { status: 'approved' })
        @success = true
        @comment = ''
      else
        @success = false
        @comment = "Unexpected assignment stage: #{a.status}"
      end
    else
      @success = false
      @comment = 'Several matching assignments'
    end
  end
end

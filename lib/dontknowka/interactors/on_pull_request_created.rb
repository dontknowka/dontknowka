require 'hanami/interactor'

class OnPullRequestCreated
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
      if a.status == 'open'
        @assignments.update(a.id, { status: 'in_progress' })
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

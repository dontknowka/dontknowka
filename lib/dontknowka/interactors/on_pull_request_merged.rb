require 'hanami/interactor'

class OnPullRequestMerged
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(update_assignment: UpdateAssignmentApprove.new)
    @update_assignment = update_assignment
  end

  def call(payload)
    repo = payload[:repository]
    res = @update_assignment.call(repo[:full_name])
    @success= res.success
    @comment = res.comment
  end
end

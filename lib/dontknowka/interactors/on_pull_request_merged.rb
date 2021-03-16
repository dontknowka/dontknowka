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
    @success = false
    @comment = 'All attempts to update assignment failed'
    5.times do
      begin
        res = @update_assignment.call(repo[:name])
        @success= res.success
        @comment = res.comment
        break
      rescue => e
        Hanami.logger.debug "Failed attempt to update approve: #{e.to_s}"
      end
    end
  end
end

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
    pull = payload[:pull_request]
    sender = payload[:sender]
    if pull[:user][:login] == sender[:login]
      @success = false
      @comment = 'Self-merge detected'
      Hanami.logger.warn "Self-merge detected: #{pull[:html_url]} by #{sender[:login]}"
    else
      @success = false
      @comment = 'All attempts to update assignment failed'
      5.times do
        begin
          res = @update_assignment.call(repo[:name])
          @success= res.success
          @comment = res.comment
          break
        rescue => e
          Hanami.logger.info "Failed attempt to update approve: #{e.to_s}"
        end
      end
    end
  end
end

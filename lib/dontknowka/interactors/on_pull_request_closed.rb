require 'hanami/interactor'

class OnPullRequestClosed
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(update_assignment: UpdateAssignmentNotReady.new, fetch_pulls: FetchPullRequests.new)
    @update_assignment = update_assignment
    @fetch_pulls = fetch_pulls
  end

  def call(payload)
    repo = payload[:repository]
    open_pulls = @fetch_pulls.call(repo[:full_name], 'open').pulls
    if open_pulls.empty?
      5.times do
        begin
          res = @update_assignment.call(repo[:name])
          @success = res.success
          @comment = res.comment
          break
        rescue => e
          Hanami.logger.info "Failed attempt to update approve: #{e.to_s}"
        end
      end
    end
  end
end

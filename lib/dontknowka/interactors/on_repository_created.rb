require 'hanami/interactor'

class OnRepositoryCreated
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(update_assignment: UpdateAssignmentStart.new)
    @update_assignment = update_assignment
  end

  def call(payload)
    sender = payload[:sender]
    if sender[:type] != 'Bot' || !sender[:login].include?('classroom')
      @success = true
      @comment = 'Uninteresting'
    else
      repo = payload[:repository]
      @success = false
      @comment = 'All attempts to update assignment failed'
      5.times do
        begin
          res = @update_assignment.call(repo[:name], repo[:full_name], repo[:html_url])
          @success = res.success
          @comment = res.comment
          break
        rescue => e
          Hanami.logger.info "Failed attempt to update repo details: #{e.to_s}"
        end
      end
    end
  end
end

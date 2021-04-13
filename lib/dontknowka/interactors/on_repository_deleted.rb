require 'hanami/interactor'

class OnRepositoryDeleted
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(delete_assignment: DeleteAssignment.new)
    @delete_assignment = delete_assignment
  end

  def call(payload)
    sender = payload[:sender]
    if sender[:type] != 'Bot' || !sender[:login].include?('classroom')
      @success = true
      @comment = 'Uninteresting'
    else
      repo = payload[:repository]
      @success = false
      @comment = 'All attempts to delete assignment failed'
      5.times do
        begin
          res = @delete_assignment.call(repo[:name])
          @success = res.success
          @comment = res.comment
          break
        rescue => e
          Hanami.logger.info "Failed attempt to delete assignment: #{e.to_s}"
        end
      end
    end
  end
end

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
      res = @update_assignment.call(repo[:full_name], repo[:html_url])
      @success = res.success
      @comment = res.comment
    end
  end
end

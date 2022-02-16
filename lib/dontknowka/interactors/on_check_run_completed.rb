require 'hanami/interactor'

class OnCheckRunCompleted
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(update_assignment: UpdateAssignmentCheck.new)
    @update_assignment = update_assignment
  end

  def call(payload)
    check_run = payload[:check_run]
    repo = payload[:repository]
    if check_run[:name] == 'build'
      if check_run[:conclusion] == 'success' || check_run[:conclusion] == 'failure'
        repo_name = (repo && repo[:name]) || ''
        pull_number = 0
        pulls = check_run[:pull_requests] || []
        if !pulls.empty?
          pull = pulls[0]
          pull_number = pull[:number]
          if repo_name.empty?
            head = pull[:head]
            repo = head[:repo]
            repo_name = repo[:name]
          end
        end
        if repo_name.nil? || repo_name.empty?
          @success = false
          @comment = 'No associated repository'
        else
          @success = false
          @comment = 'All attempts to update assignment failed'
          5.times do
            begin
              res = @update_assignment.call(repo_name, pull_number, check_run[:conclusion], check_run[:id], check_run[:html_url], check_run[:completed_at])
              @success = res.success
              @comment = res.comment
              break
            rescue => e
              Hanami.logger.info "Failed attempt to update check_run: #{e.to_s}"
            end
          end
        end
      else
        @success = true
        @comment = "Uninteresting conclusion '#{check_run[:conclusion]}'"
      end
    else
      @success = true
      @comment = "Unknown check suite #{check_run[:name]}"
    end
  end
end

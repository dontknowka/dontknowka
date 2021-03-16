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
        repo_name = ''
        if repo.nil?
          pulls = check_run[:pull_requests]
          if !pulls.empty?
            head = pulls[0][:head]
            repo = head[:repo]
            repo_name = repo[:name]
          end
        else
          repo_name = repo[:name]
        end
        if repo_name.nil? || repo_name.empty?
          @success = false
          @comment = 'No associated repository'
        else
          @success = false
          @comment = 'All attempts to update assignment failed'
          5.times do
            begin
              res = @update_assignment.call(repo_name, check_run[:conclusion], check_run[:id], check_run[:html_url])
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

require 'hanami/interactor'

class OnCheckRunCompleted
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(assignments: AssignmentRepository.new)
    @assignments = assignments
  end

  def call(payload)
    check_run = payload[:check_run]
    repo = payload[:repository]
    if check_run[:name] == 'build'
      if check_run[:conclusion] == 'success' || check_run[:conclusion] == 'failure'
        pulls = check_run[:pull_requests]
        if !pulls.empty?
          head = pulls[0][:head]
          repo = head[:repo]
        end
        if repo.nil? || repo[:name].nil?
          @success = false
          @comment = 'No associated repository'
        else
          ass = @assignments.by_repo(repo[:name])
          case ass.size
          when 0
            @success = false
            @comment = 'No such assignment'
          when 1
            a = ass[0]
            case a.status
            when 'in_progress'
              if check_run[:conclusion] == 'success'
                @assignments.update(a.id, { status: 'ready' })
              end
              @success = true
              @comment = ''
            when 'ready'
              if check_run[:conclusion] == 'failure'
                @assignments.update(a.id, { status: 'in_progress' })
              end
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

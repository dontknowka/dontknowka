module Events
  module Controllers
    module Home
      class New
        include Events::Action

        accept :json

        def initialize(events_switch: EventsSwitch.new,
                       on_repository_created: OnRepositoryCreated.new,
                       on_repository_deleted: OnRepositoryDeleted.new,
                       on_check_run: OnCheckRunCompleted.new,
                       on_pr_merged: OnPullRequestMerged.new,
                       on_pr_closed: OnPullRequestClosed.new,
                       on_request_changes: OnRequestChanges.new)
          @switch = events_switch
          @on_repository_created = on_repository_created
          @on_repository_deleted = on_repository_deleted
          @on_check_run = on_check_run
          @on_pr_merged = on_pr_merged
          @on_pr_closed = on_pr_closed
          @on_request_changes = on_request_changes
        end

        def call(params)
          event = @switch.call(request.env['HTTP_X_GITHUB_EVENT'], params).event
          repo_name = params[:repository] ? params[:repository][:name] : ''
          Hanami.logger.info "Received event #{event.to_s} #{repo_name}"
          case event
          when :create_repository
            res = @on_repository_created.call(params)
            if !res.success
              Hanami.logger.warn "Unsuccessful 'repository created' event processing - #{res.comment} for #{repo_name}"
            else
              Hanami.logger.debug "Successful 'repository created' event processing - #{res.comment}"
            end
          when :delete_repository
            res = @on_repository_deleted.call(params)
            if !res.success
              Hanami.logger.warn "Unsuccessful 'repository deleted' event processing - #{res.comment}"
            else
              Hanami.logger.debug "Successful 'repository deleted' event processing - #{res.comment}"
            end
          when :check_run
            res = @on_check_run.call(params)
            if !res.success
              Hanami.logger.warn "Unsuccessful 'check run completed' event processing - #{res.comment}"
            else
              Hanami.logger.debug "Successful 'check run completed' event processing - #{res.comment}"
            end
          when :open_pr
            Hanami.logger.debug 'Pull request is opened'
          when :merge_pr
            res = @on_pr_merged.call(params)
            if !res.success
              Hanami.logger.warn "Unsuccessful 'pull request merged' event processing - #{res.comment}"
            else
              Hanami.logger.debug "Successful 'pull request merged' event processing - #{res.comment}"
            end
          when :close_pr
            res = @on_pr_closed.call(params)
            if !res.success
              Hanami.logger.warn "Unsuccessful 'pull request closed' event processing - #{res.comment}"
            else
              Hanami.logger.debug "Successful 'pull request closed' event processing - #{res.comment}"
            end
          when :request_changes
            res = @on_request_changes.call(params)
            if !res.success
              Hanami.logger.warn "Unsuccessful 'changes requested' event processing - #{res.comment}"
            else
              Hanami.logger.debug "Successful 'changes requested' event processing - #{res.comment}"
            end
          end
          status 201, 'Success'
        end

        private

        def verify_csrf_token?
          false
        end
      end
    end
  end
end

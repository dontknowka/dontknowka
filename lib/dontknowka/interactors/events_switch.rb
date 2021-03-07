require 'hanami/interactor'

class EventsSwitch
  include Hanami::Interactor

  expose :event

  def call(event_name, payload)
    @event = :uninteresting
    case event_name
    when 'check_run'
      case payload[:action]
      when 'completed'
        @event = :check_run
      end
    when 'repository'
      case payload[:action]
      when 'created'
        @event = :create_repository
      end
    when 'pull_request'
      case payload[:action]
      when 'opened'
        @event = :open_pr
      when 'closed'
        if (payload[:pull_request] || {})[:merged]
          @event = :merge_pr
        end
      end
    end
  end
end

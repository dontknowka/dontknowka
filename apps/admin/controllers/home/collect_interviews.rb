module Admin
  module Controllers
    module Home
      class CollectInterviews
        include Admin::Action

        def initialize(fetch_interviews: FetchInterviews.new)
          @fetch_interviews = fetch_interviews
        end

        def call(params)
          data = params[:homework]
          if data.nil? || data[:homework_instance_id].nil?
            halt 404
          end
          res = @fetch_interviews.call(Integer(data[:homework_instance_id]))
          if !res.success
            Hanami.logger.warn "Collect interviews for #{data[:homework_instance_id]} failed with #{res.comment}"
          end
          redirect_to routes.root_path
        end
      end
    end
  end
end

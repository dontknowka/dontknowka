module Admin
  module Controllers
    module Home
      class AddTeamToReviewers
        include Admin::Action

        def initialize(fetch_repos: FetchInstanceRepositories.new,
                       fetch_pulls: FetchPullRequests.new,
                       request_reviews: RequestReviews.new)
          @fetch_repos = fetch_repos
          @fetch_pulls = fetch_pulls
          @request_reviews = request_reviews
        end

        def call(params)
          data = params[:review_mapping]
          if data.nil? || data[:homework].nil? || data[:team].nil?
            halt 404
          end
          @fetch_repos.call(data[:homework]).repos.each do |repo|
            @fetch_pulls.call(repo[:full_name], 'open').pulls.each do |pull|
              Hanami.logger.debug "Add team #{data[:team]} to #{repo[:name]}{#{pull[:number]}} reviewers"
              @request_reviews.call(repo[:full_name], pull[:number], data[:team])
            end
          end
          redirect_to routes.root_path
        end
      end
    end
  end
end

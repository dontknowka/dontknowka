module Admin
  module Controllers
    module Home
      class FixReviews
        include Admin::Action

        def initialize(fetch_repos: FetchClassroomRepositories.new,
                       fetch_pulls: FetchPullRequests.new,
                       fetch_reviews: FetchReviews.new,
                       get_owner: GetRepoOwner.new,
                       assignments: AssignmentRepository.new,
                       reviews: ReviewRepository.new)
          @fetch_repos = fetch_repos
          @fetch_pulls = fetch_pulls
          @fetch_reviews = fetch_reviews
          @get_owner = get_owner
          @assignments = assignments
          @reviews = reviews
        end

        def call(params)
          @fetch_repos.call.repos.each do |r|
            repo = r[:full_name]
            owner = @get_owner.call(repo)
            if owner.login.nil?
              Hanami.logger.info "Not found an owner for repository #{repo}"
              next
            end
            ass = @assignments.by_student_id(owner.github_id).detect {|a| r[:name].start_with? a.homework_instance.name }
            if ass.nil?
              Hanami.logger.info "No assignment for repository #{r[:name]}"
              next
            end
            pulls = @fetch_pulls.call(repo).pulls # sorted from newest to oldest by Github API
            pulls.each do |pull|
              @fetch_reviews.call(repo, pull[:number]).reviews.each do |r|
                if review = @reviews.find(r[:id])
                  @reviews.update(review.id,
                                  teacher_id: r[:user][:id],
                                  submitted_at: r[:submitted_at],
                                  number_of_criticism: r[:body].lines.map(&:strip).count {|x| x.start_with? '- [ ] ', '- [] '})
                else
                  @reviews.create(id: r[:id],
                                  assignment_id: ass.id,
                                  teacher_id: r[:user][:id],
                                  pull: pull[:number],
                                  submitted_at: r[:submitted_at],
                                  number_of_criticism: r[:body].lines.map(&:strip).count {|x| x.start_with? '- [ ] ', '- [] '},
                                  url: r[:html_url])
                end
              end
            end
            sleep 30
          end
          redirect_to routes.root_path
        end
      end
    end
  end
end

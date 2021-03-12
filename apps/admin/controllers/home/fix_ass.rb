module Admin
  module Controllers
    module Home
      class FixAss
        include Admin::Action

        def initialize(fetch_repos: FetchClassroomRepositories.new,
                       fetch_pulls: FetchPullRequests.new,
                       fetch_reviews: FetchReviews.new,
                       fetch_commits: FetchCommits.new,
                       fetch_check_runs: FetchCheckRuns.new,
                       get_owner: GetRepoOwner.new,
                       homework_instances: HomeworkInstanceRepository.new,
                       assignments: AssignmentRepository.new,
                       reviews: ReviewRepository.new,
                       check_runs: CheckRunRepository.new)
          @fetch_repos = fetch_repos
          @fetch_pulls = fetch_pulls
          @fetch_reviews = fetch_reviews
          @fetch_commits = fetch_commits
          @fetch_check_runs = fetch_check_runs
          @get_owner = get_owner
          @homework_instances = homework_instances
          @assignments = assignments
          @reviews = reviews
          @check_runs = check_runs
        end

        def call(params)
          @fetch_repos.call.repos.each do |r|
            repo = r[:full_name]
            owner = @get_owner.call(repo)
            if !owner.login.nil?
              asses = @assignments.by_student_id(owner.github_id)
              ass = asses.detect {|a| r[:name].start_with? a.homework_instance.name }
              if ass.nil?
                Hanami.logger.debug "No assignment for repository #{r[:name]}, creating it"
                instance_name = r[:name].delete_suffix("-#{owner.login}")
                instance = @homework_instances.by_name(instance_name)
                if instance.nil?
                  Hanami.logger.debug "No instance for #{instance_name} (#{owner.login})"
                else
                  ass = @assignments.create({ student_id: owner.github_id,
                                              homework_instance_id: instance.id,
                                              prepare_deadline: instance.homework.prepare_deadline,
                                              approve_deadline: instance.homework.approve_deadline,
                                              status: 'in_progress',
                                              url: r[:html_url],
                                              repo: repo })
                end
              elsif ass.status == 'open'
                ass = @assignments.update(ass.id, { status: 'in_progress', url: r[:html_url], repo: repo })
                Hanami.logger.debug "Set 'in progress' for #{r[:name]}"
              elsif ass.repo != repo
                Hanami.logger.debug "Fixing assignment repo name from #{ass.repo} to #{repo}"
                ass = @assignments.update(ass.id, { url: r[:html_url], repo: repo })
              else
                Hanami.logger.debug "Assignment for #{r[:name]} is already 'in_progress'"
              end
              pulls = @fetch_pulls.call(repo, 'closed').pulls
              runs = []
              pulls.concat(@fetch_pulls.call(repo, 'open').pulls).each do |pull|
                @fetch_reviews.call(repo, pull[:number]).reviews.each do |r|
                  review = @reviews.find(r[:id])
                  if review.nil?
                    @reviews.create({ id: r[:id],
                                      assignment_id: ass.id,
                                      teacher_id: r[:user][:id],
                                      pull: pull[:number],
                                      submitted_at: r[:submitted_at],
                                      number_of_criticism: r[:body].lines.map(&:strip).count {|x| x.start_with? '- [ ] '},
                                      url: r[:html_url] })
                  end
                end
                runs.push(*@fetch_commits.call(repo, pull).commits.flat_map {|c| @fetch_check_runs.call(c).check_runs})
              end
              runs.each do |cr|
                if @check_runs.find(cr['id']).nil?
                  @check_runs.create(id: cr['id'], assignment_id: ass.id, url: cr['html_url'])
                end
              end
              last_pull = pulls.detect {|p| p[:merge_commit_sha] }
              if !last_pull.nil?
                @assignments.update(ass.id, { status: 'approved' })
              else
                last_check = runs.sort_by {|cr| DateTime.parse(cr['completed_at'])}.last
                if !last_check.nil? && last_check['conclusion'] == 'success'
                  @assignments.update(ass.id, { status: 'ready' })
                end
              end
            end
          end
          redirect_to routes.root_path
        end
      end
    end
  end
end

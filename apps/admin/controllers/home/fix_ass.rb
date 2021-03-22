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
                       check_master_protection: CheckMasterProtection.new,
                       initialize_repo: InitializeRepo.new,
                       homework_instances: HomeworkInstanceRepository.new,
                       assignments: AssignmentRepository.new,
                       reviews: ReviewRepository.new,
                       check_runs: CheckRunRepository.new,
                       team_mappings: TeamMappingRepository.new)
          @fetch_repos = fetch_repos
          @fetch_pulls = fetch_pulls
          @fetch_reviews = fetch_reviews
          @fetch_commits = fetch_commits
          @fetch_check_runs = fetch_check_runs
          @get_owner = get_owner
          @check_master_protection = check_master_protection
          @initialize_repo = initialize_repo
          @homework_instances = homework_instances
          @assignments = assignments
          @reviews = reviews
          @check_runs = check_runs
          @team_mappings = team_mappings
        end

        def call(params)
          @fetch_repos.call.repos.each do |r|
            repo = r[:full_name]
            owner = @get_owner.call(repo)
            if !owner.login.nil?
              instance = nil
              asses = @assignments.by_student_id(owner.github_id)
              ass = asses.detect {|a| r[:name].start_with? a.homework_instance.name }
              if ass.nil?
                Hanami.logger.info "No assignment for repository #{r[:name]}, creating it"
                instance_name = r[:name].delete_suffix("-#{owner.login}")
                instance = @homework_instances.by_name(instance_name)
                if instance.nil?
                  Hanami.logger.warn "No instance for #{instance_name} (#{owner.login})"
                  next
                else
                  ass = @assignments.create({ student_id: owner.github_id,
                                              homework_instance_id: instance.id,
                                              prepare_deadline: instance.homework.prepare_deadline,
                                              approve_deadline: instance.homework.approve_deadline,
                                              status: 'in_progress',
                                              url: r[:html_url],
                                              repo: repo })
                end
              elsif ass.status == 'approved'
                Hanami.logger.info "Assignment for #{r[:name]} is already approved"
                next
              else
                ass = @assignments.update(ass.id, { status: 'in_progress', url: r[:html_url], repo: repo })
              end
              pulls = @fetch_pulls.call(repo).pulls # sorted from newest to oldest by Github API
              last_pull = nil
              if !pulls.empty? && pulls[0][:merged_at]
                last_pull = pulls[0]
              end
              Hanami.logger.info "Found PRs: #{pulls.map {|p| p[:html_url]}.join}"
              runs = []
              pulls.each do |pull|
                @fetch_reviews.call(repo, pull[:number]).reviews.each do |r|
                  if @reviews.find(r[:id]).nil?
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
                  @check_runs.create(id: cr['id'], assignment_id: ass.id, url: cr['html_url'], completed_at: cr['completed_at'])
                else
                  @check_runs.update(cr['id'], completed_at: cr['completed_at'])
                end
              end
              if !last_pull.nil?
                # cannot check for 'self-merge' here, unfortunately
                Hanami.logger.info "Last closed PR: #{last_pull[:html_url]}"
                @assignments.update(ass.id, { status: 'approved' })
              else
                last_check = runs.sort_by {|cr| DateTime.parse(cr['completed_at'])}.last
                Hanami.logger.info "Found last check run: #{last_check[:html_url]}" unless last_check.nil?
                if !last_check.nil? && last_check['conclusion'] == 'success'
                  @assignments.update(ass.id, { status: 'ready' })
                end
              end
              check_protection = @check_master_protection.call(repo)
              if check_protection.valid && !check_protection.protected
                Hanami.logger.info "Found repository without master branch protected: #{repo}"
                if instance.nil?
                  instance_name = r[:name].delete_suffix("-#{owner.login}")
                  instance = @homework_instances.by_name(instance_name)
                  if instance.nil?
                    Hanami.logger.warn "No instance for #{instance_name} (#{owner.login})"
                    next
                  end
                end
                team_mapping = @team_mappings.by_instance(instance.id)
                if team_mapping.nil?
                  Hanami.logger.warn "Not found TA team responsible for #{instance.name}"
                  next
                end
                team = team_mapping.teacher_team
                res = @initialize_repo.call(team.id, team.slug, repo)
                if !res.success
                  Hanami.logger.warn "Failed to initialize repository #{repo}: #{res.comment}"
                end
              end
            else
              Hanami.logger.info "Not found an owner for repository #{repo}"
            end
          end
          redirect_to routes.root_path
        end
      end
    end
  end
end

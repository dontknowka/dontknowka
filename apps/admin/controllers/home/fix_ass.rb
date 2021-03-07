module Admin
  module Controllers
    module Home
      class FixAss
        include Admin::Action

        def initialize(fetch_repos: FetchClassroomRepositories.new,
                       fetch_pulls: FetchPullRequests.new,
                       get_owner: GetRepoOwner.new,
                       homework_instances: HomeworkInstanceRepository.new,
                       assignments: AssignmentRepository.new)
          @fetch_repos = fetch_repos
          @fetch_pulls = fetch_pulls
          @get_owner = get_owner
          @homework_instances = homework_instances
          @assignments = assignments
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
              else
                Hanami.logger.debug "Assignment for #{r[:name]} is already 'in_progress'"
              end
              last_pull = @fetch_pulls.call(repo, 'closed').pulls.detect {|p| p[:merge_commit_sha] }
              if !last_pull.nil?
                @assignments.update(ass.id, { status: 'approved' })
              end
            end
          end
          redirect_to routes.root_path
        end
      end
    end
  end
end

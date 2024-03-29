require 'hanami/interactor'

class UpdateAssignmentStart
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(assignments: AssignmentRepository.new,
                 team_mappings: TeamMappingRepository.new,
                 initialize_repo: InitializeRepo.new)
    @assignments = assignments
    @team_mappings = team_mappings
    @initialize_repo = initialize_repo
  end

  def call(repo, repo_full, repo_url)
    ass = @assignments.by_repo(repo)
    case ass.size
    when 0
      @success = false
      @comment = 'No associated assignment'
    when 1
      a = ass[0]
      if a.status == 'open'
        ta = @team_mappings.by_instance(a.homework_instance_id)
        if ta.nil?
          @success = false
          @comment = "Not found TA mapping for HW instance #{a.homework_instance_id}"
        else
          repo_result = @initialize_repo.call(ta.teacher_team.id, ta.teacher_team.slug, repo_full)
          if repo_result.success
            @assignments.update(a.id, { status: 'in_progress', url: repo_url, repo: repo_full })
            @success = true
            @comment = repo_result.comment
          else
            @success = false
            @comment = repo_result.comment
            raise @comment
          end
        end
      else
        @success = false
        @comment = "Unexpected assignment stage: #{a.status}"
      end
    else
      @success = false
      @comment = 'Several matching assignments'
    end
  end
end

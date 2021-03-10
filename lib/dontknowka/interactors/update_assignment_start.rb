require 'hanami/interactor'

class UpdateAssignmentStart
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(assignments: AssignmentRepository.new,
                 team_mappings: TeamMapingRepository.new,
                 initialize_repo: InitializeRepo.new)
    @assignments = assignments
    @team_mappings = team_mappings
    @initialize_repo = initialize_repo
  end

  def call(repo, repo_url)
    ass = @assignments.by_repo(repo)
    case ass.size
    when 0
      @success = false
      @comment = 'No associated assignment'
    when 1
      a = ass[0]
      ta = @team_mappings.by_instance(a.homework_instance_id)
      if ta.nil?
        @success = false
        @comment = "Not found TA mapping for HW instance #{a.homework_instance_id}"
      else
        @initialize_repo.call(ta.teacher_team.id, ta.teacher_team.slug, repo)
        if a.status == 'open'
          @assignments.update(a.id, { status: 'in_progress', url: repo_url })
          @success = true
          @comment = ''
        else
          @success = false
          @comment = "Unexpected assignment stage: #{a.status}"
        end
      end
    else
      @success = false
      @comment = 'Several matching assignments'
    end
  end
end

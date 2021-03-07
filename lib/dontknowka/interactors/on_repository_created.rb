require 'hanami/interactor'

class OnRepositoryCreated
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(assignments: AssignmentRepository.new,
                 teacher_mappings: TeacherMappingRepository.new,
                 add_team_repo: AddTeamRepo.new,
                 protect_branch: ProtectBranch.new)
    @assignments = assignments
    @teacher_mappings = teacher_mappings
    @add_team_repo = add_team_repo
    @protect_branch = protect_branch
  end

  def call(payload)
    sender = payload[:sender]
    if sender[:type] != 'Bot' || !sender[:login].include?('classroom')
      @success = true
      @comment = 'Uninteresting'
    else
      repo = payload[:repository]
      ass = @assignments.by_repo(repo[:name])
      case ass.size
      when 0
        @success = false
        @comment = 'No such assignment'
      when 1
        a = ass[0]
        ta = @teacher_mappings.by_instance(a.homework_instance_id)
        if ta.nil?
          @success = false
          @comment = "Not found TA mapping for HW instance #{a.homework_instance_id}"
        else
          @add_team_repo.call(ta.teacher_id, repo[:full_name])
          @protect_branch.call(repo[:full_name], [], [ta.teacher.login])
          if a.status == 'open'
            @assignments.update(a.id, { status: 'in_progress', url: repo[:html_url] })
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
end

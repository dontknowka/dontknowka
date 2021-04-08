require 'hanami/interactor'

class InitializeRepo
  include Hanami::Interactor

  expose :success
  expose :comment

  def initialize(add_team_repo: AddTeamRepo.new,
                 protect_branch: ProtectBranch.new)
    @add_team_repo = add_team_repo
    @protect_branch = protect_branch
  end

  def call(team_id, team_slug, repo)
    if @add_team_repo.call(team_id, repo).valid
      if @protect_branch.call(repo, [], [team_slug]).valid
        @success = true
        @comment = ''
      else
        @success = false
        @comment = 'Protect branch failed'
      end
    else
      @success = false
      @comment = 'Add team to repo failed'
    end
  end
end

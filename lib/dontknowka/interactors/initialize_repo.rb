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
    @add_team_repo.call(team_id, repo)
    @protect_branch.call(repo, [], [team_slug])
    @success = true
    @comment = ''
  end
end

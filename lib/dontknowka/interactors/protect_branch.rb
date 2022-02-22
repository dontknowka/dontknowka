require 'hanami/interactor'

class ProtectBranch
  include Hanami::Interactor

  expose :valid

  def initialize(client: OrgClient.new, branch: 'master', checks: ['build'])
    @client = client
    @branch = branch
    @checks = checks
  end

  def call(repo_name, users, teams)
    begin
      @client.protect_branch(repo_name, @branch, { enforce_admins: true,
                                                   allow_force_pushes: false,
                                                   allow_deletions: false,
                                                   required_status_checks: { strict: true, contexts: @checks },
                                                   restrictions: { users: users, teams: teams },
                                                   required_pull_request_reviews: { dismiss_stale_reviews: true,
                                                                                    require_code_owner_reviews: true,
                                                                                    required_approving_review_count: 1 } })
      if @client.branch_protection(repo_name, @branch)
        @valid = true
      else
        @valid = false
        Hanamo.logger.warn "Branch protection setup silently failed for #{repo_name}" if Hanami.logger
      end
    rescue Octokit::NotFound
      Hanami.logger.warn "Not found repository #{repo_name} while trying to set master branch protection?" if Hanami.logger
      @valid = false
    end
  end
end

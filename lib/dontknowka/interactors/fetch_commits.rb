require 'hanami/interactor'

class FetchCommits
  include Hanami::Interactor

  expose :commits

  def initialize(client: OrgClient.new)
    @client = client
  end

  def call(repo_name, pull)
    begin
      @commits = @client.commits(repo_name, pull[:head][:ref])
    rescue Octokit::NotFound
      Hanami.logger.debug "Not found commits for #{repo_name}:#{pull[:head][:ref]}"
      @commits = []
    end
  end
end

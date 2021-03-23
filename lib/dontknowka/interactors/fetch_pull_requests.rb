require 'hanami/interactor'

class FetchPullRequests
  include Hanami::Interactor

  expose :pulls

  def initialize(client: OrgClient.new)
    @client = client
  end

  def call(repo_name, state = 'all')
    begin
      @pulls = @client.pull_requests(repo_name, state: state)
    rescue Octokit::NotFound
      Hanami.logger.debug "Not found repository #{repo_name}?"
      @pulls = []
    end
  end
end

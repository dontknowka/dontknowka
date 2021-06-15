require 'hanami/interactor'

class FetchComments
  include Hanami::Interactor

  expose :success
  expose :comment
  expose :comments

  def initialize(client: OrgClient.new)
    @client = client
  end

  def call(repo_name)
    pulls = []
    begin
      pulls = @client.pull_requests(repo_name, state: 'closed').map {|pr| pr[:number]}
      @comments = pulls
        .flat_map {|n| [].concat(@client.issue_comments(repo_name, n), @client.pull_request_reviews(repo_name, n))}
        .sort{|a,b| (a[:submitted_at] || a[:created_at]) <=> (b[:submitted_at] || b[:created_at])}
      @success = true
    rescue Octokit::NotFound
      @success = false
      @comment = "Not found pull requests for #{repo_name}"
      @comments = []
    rescue Octokit::InvalidRepository
      @success = false
      @comment = "Not found repository #{repo_name}"
      @comments = []
    end
  end
end

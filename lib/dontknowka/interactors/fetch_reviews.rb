require 'hanami/interactor'

class FetchReviews
  include Hanami::Interactor

  expose :reviews

  def initialize(client: OrgClient.new)
    @client = client
  end

  def call(repo_name, pull)
    begin
      @reviews = @client
        .pull_request_reviews(repo_name, pull)
        .filter {|r| r[:state].downcase == 'changes_requested' && r[:user]}
    rescue Octokit::NotFound
      Hanami.logger.debug "Not found pull request #{pull} for repository #{repo_name}?"
      @reviews = []
    end
  end
end

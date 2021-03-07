require 'hanami/interactor'

class FetchRepositories
  include Hanami::Interactor

  expose :repos

  def initialize(client: OrgClient.new, org: ENV['GITHUB_ORG'])
    @client = client
    @org = org
  end

  def call
    @repos = @client.org_repos(@org)
  end
end

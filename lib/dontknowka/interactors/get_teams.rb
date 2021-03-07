require 'hanami/interactor'

class GetTeams
  include Hanami::Interactor

  expose :teams

  def initialize(client: OrgClient.new, org: ENV['GITHUB_ORG'])
    @client = client
    @org = org
  end

  def call()
    @teams = @client.org_teams(@org)
  end
end

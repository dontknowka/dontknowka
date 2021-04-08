require 'hanami/interactor'

class AddTeamRepo
  include Hanami::Interactor

  expose :valid

  def initialize(client: OrgClient.new)
    @client = client
  end

  def call(team_id, repo_name)
    @valid = @client.add_team_repo(team_id, repo_name, permission: 'push')
  end
end

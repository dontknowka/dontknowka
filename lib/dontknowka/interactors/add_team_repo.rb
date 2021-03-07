require 'hanami/interactor'

class AddTeamRepo
  include Hanami::Interactor

  expose :ok

  def initialize(client: OrgClient.new)
    @client = client
  end

  def call(team_id, repo_name)
    @ok = @client.add_team_repo(team_id, repo_name, permission: 'push')
  end
end

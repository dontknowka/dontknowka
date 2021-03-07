require 'hanami/interactor'

class GetRepoOwner
  include Hanami::Interactor

  expose :login
  expose :github_id

  def initialize(client: OrgClient.new, org: ENV['GITHUB_ORG'], team: ENV['STUDENT_TEAM_ID'])
    @client = client
    @org = org
    @team = team
  end

  def call(repo_name)
    collabs = @client.collaborators(repo_name)
    owner = collabs.detect do |c|
      begin
        @client.team_membership(@team, c[:login])[:role] == 'member'
      rescue Octokit::NotFound
        false
      end
    end
    if !owner.nil?
      @login = owner[:login]
      @github_id = owner[:id]
    else
      @login = nil
      @github_id = nil
    end
  end
end

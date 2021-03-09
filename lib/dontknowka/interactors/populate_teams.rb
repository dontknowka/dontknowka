require 'hanami/interactor'

class PopulateTeams
  include Hanami::Interactor

  expose :ok

  def initialize(create_team: CreateTeam.new,
                 client: OrgClient.new,
                 org: ENV['GITHUB_ORG'],
                 root_team: ENV['TA_TEAM'])
    @create_team = create_team
    @client = client
    @org = org
    @root_team = root_team
  end

  def call()
    @ok = false
    begin
      root = @client.org_teams(@org).detect {|x| x.name == @root_team}
    rescue => e
      Hanami.logger.debug "Failed to fetch root team: #{e.to_s}"
    end
    teams = []
    if !root.nil?
      begin
        teams = @client.child_teams(root.id, :accept => "application/vnd.github.hellcat-preview+json")
        @ok = true
      rescue => e
        Hanami.logger.debug "Failed to fetch child teams: #{e.to_s}"
      end
    end
    teams.each {|t| @create_team.call(t.id, t.slug, t.name)}
  end
end

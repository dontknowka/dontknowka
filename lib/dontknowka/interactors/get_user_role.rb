require 'hanami/interactor'

class GetUserRole
  include Hanami::Interactor

  expose :role

  def initialize(client: OrgClient.new, org: nil, ta_team: nil)
    @client = client
    @org = org
    @ta_team = ta_team
  end

  def call(user)
    team = @client.org_teams(@org).detect { |x| x.name == @ta_team }
    if @client.team_member?(team.id, user)
      @role = 'teacher'
    else
      @role = 'student'
    end
  end
end

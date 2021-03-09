require 'hanami/interactor'

class PopulateTeachers
  include Hanami::Interactor

  expose :ok

  def initialize(create_teacher: CreateTeacher.new,
                 client: OrgClient.new,
                 org: ENV['GITHUB_ORG'],
                 root_team: ENV['TA_TEAM'])
    @create_teacher = create_teacher
    @client = client
    @org = org
    @root_team = root_team
  end

  def call()
    @ok = true
    begin
      root = @client.org_teams(@org).detect {|x| x.name == @root_team}
    rescue => e
      Hanami.logger.debug "Failed to fetch root team: #{e.to_s}"
      @ok = false
    end
    members = []
    if !root.nil?
      begin
        members = @client.team_members(root.id)
      rescue => e
        Hanami.logger.debug "Failed to fetch team members: #{e.to_s}"
        @ok = false
      end
    end
    members.each do |m|
      begin
        user = @client.user(m.login)
        @create_teacher.call(user.id, user.login, user.name, user.email, user.avatar_url)
      rescue => e
        Hanami.logger.debug "Failed to fetch user data: #{e.to_s}"
        @ok = false
      end
    end
  end
end

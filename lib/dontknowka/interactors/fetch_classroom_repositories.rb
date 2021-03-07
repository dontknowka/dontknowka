require 'hanami/interactor'

class FetchClassroomRepositories
  include Hanami::Interactor

  expose :repos

  def initialize(client: OrgClient.new, org: ENV['GITHUB_ORG'])
    @client = client
    @org = org
  end

  def call
    @repos = @client.org_repos(@org).filter {|x| x[:description] && x[:description].include?("Classroom") }
  end
end

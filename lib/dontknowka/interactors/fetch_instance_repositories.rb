require 'hanami/interactor'

class FetchInstanceRepositories
  include Hanami::Interactor

  expose :repos

  def initialize(client: OrgClient.new, org: ENV['GITHUB_ORG'])
    @client = client
    @org = org
  end

  def call(name)
    @repos = @client.org_repos(@org).filter {|x| x[:name].start_with?("#{name}-") && x[:description].include?("Classroom") }
  end
end

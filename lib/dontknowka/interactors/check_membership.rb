require 'hanami/interactor'

class CheckMembership
  include Hanami::Interactor

  expose :result

  def initialize(client: OrgClient.new, org: ENV['GITHUB_ORG'])
    @client = client
    @org = org
  end

  def call(user)
    @result = @client.org_member?(@org, user)
  end
end

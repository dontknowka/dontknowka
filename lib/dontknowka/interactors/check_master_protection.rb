require 'hanami/interactor'

class CheckMasterProtection
  include Hanami::Interactor

  expose :valid
  expose :protected

  def initialize(client: OrgClient.new)
    @client = client
  end

  def call(repo_name)
    begin
      m = @client.branches(repo_name).detect {|b| b[:name] && b[:name] == 'master'}
      @valid = true
      @protected = m[:protected]
    rescue Octokit::NotFound
      @valid = false
      Hanami.logger.info "Not found repository or its master branch: #{repo_name}"
    end
  end
end

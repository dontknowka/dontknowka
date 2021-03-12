require 'json'
require 'rest-client'

require 'hanami/interactor'

class FetchCheckRuns
  include Hanami::Interactor

  expose :valid
  expose :check_runs

  def initialize(client: RestClient, token: ENV['ORG_CLIENT_TOKEN'])
    @client = client
    @token = token
  end

  def call(commit)
    headers = { :Authorization => "Bearer #{@token}", :accept => 'application/vnd.github.v3+json', :content_type => :json }
    url = "#{commit[:url]}/check-runs?check_name=build&status=completed&per_page=100"
    begin
      reply = @client.get(url, headers)
      if reply.code == 200
        @check_runs = JSON.parse(reply.body)['check_runs']
        @valid = true
      else
        @check_runs = []
        @valid = false
        Hanami.logger.info "Failed to fetch check runs for #{commit[:sha]}: HTTP code #{reply.code}"
      end
    rescue => e
      Hanami.logger.info "Failed to fetch check runs for #{commit[:sha]}: #{e.to_s}"
      @valid = false
    end
  end
end

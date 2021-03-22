require 'json'
require 'rest-client'

require 'hanami/interactor'

class RequestReviews
  include Hanami::Interactor

  expose :valid

  def initialize(client: RestClient, token: ENV['ORG_CLIENT_TOKEN'])
    @client = client
    @token = token
  end

  def call(repo, pull_number, team_slug)
    headers = { :Authorization => "Bearer #{@token}", :accept => :json, :content_type => :json }
    url = "https://api.github.com/repos/#{repo}/pulls/#{pull_number}/requested_reviewers"
    payload = { team_reviewers: [team_slug] }.to_json
    Hanami.logger.debug "POSTing to #{url} with headers #{headers.to_s} and payload #{payload}"
    begin
      @client.post(url, payload, headers)
    rescue => e
      Hanami.logger.warn e.to_s
      @valid = false
    else
      @valid = true
    end
  end
end

require 'json'
require 'rest-client'

require 'hanami/interactor'

class InviteUser
  include Hanami::Interactor

  expose :valid

  def initialize(client: RestClient, org: ENV['GITHUB_ORG'], token: ENV['ORG_CLIENT_TOKEN'], team_id: nil)
    @client = client
    @org = org
    @token = token
    @teams = [Integer(team_id)]
  end

  def call(user)
    headers = { :Authorization => "Bearer #{@token}", :accept => :json, :content_type => :json }
    url = "https://api.github.com/orgs/#{@org}/invitations"
    payload = { invitee_id: user, team_ids: @teams }.to_json
    Hanami.logger.debug "POSTing to #{url} with headers #{headers.to_s} and payload #{payload}"
    begin
      @client.post(url, payload, headers)
    rescue => e
      Hanami.logger.debug e.to_s
      @valid = false
    else
      @valid = true
    end
  end
end

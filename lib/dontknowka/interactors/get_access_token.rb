require 'rest_client'
require 'json'

require 'hanami/interactor'

class GetAccessToken
  include Hanami::Interactor

  expose :valid
  expose :token

  def initialize(client: RestClient, client_id: ENV['LOGIN_CLIENT_ID'], client_secret: ENV['LOGIN_CLIENT_SECRET'])
    @client = client
    @client_id = client_id
    @client_secret = client_secret
  end

  def call(code, state)
    begin
      result = @client.post('https://github.com/login/oauth/access_token',
                            {:client_id => @client_id,
                             :client_secret => @client_secret,
                             :code => code,
                             :state => state},
                             :accept => :json)
    rescue
      @valid = false
    else
      @token = JSON.parse(result)['access_token']
      @valid = true
    end
  end
end

require 'rest_client'
require 'json'

require 'hanami/interactor'

class FetchUser
  include Hanami::Interactor

  expose :valid
  expose :login
  expose :name
  expose :email
  expose :avatar
  expose :github_id

  def initialize(client: RestClient)
    @client = client
  end

  def call(access_token)
    headers = { :Authorization => "Bearer #{access_token}", :accept => :json }
    begin
      result = @client.get('https://api.github.com/user', headers)
    rescue
      @valid = false
    else
      result = JSON.parse(result)
      if result['email'].nil?
        begin
          private_emails = JSON.parse(@client.get('https://api.github.com/user/emails', headers))
        rescue => e
          Hanami.logger.debug "Failed to fetch user emails: #{e.to_s}"
        else
          result['email'] = private_emails.detect { |x| x['primary'] } ['email']
        end
      end
      @login = result['login']
      @name = result['name']
      @email = result['email']
      @avatar = result['avatar_url']
      @github_id = result['id']
      @valid = true
    end
  end
end

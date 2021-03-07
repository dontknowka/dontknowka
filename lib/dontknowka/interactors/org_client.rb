require 'octokit'

class OrgClient < Octokit::Client
  def initialize
    token = ENV['ORG_CLIENT_TOKEN']
    super(access_token: token, per_page: 100)
    @auto_paginate = true
  end
end

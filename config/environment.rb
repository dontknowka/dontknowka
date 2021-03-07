require 'bundler/setup'
require 'hanami/setup'
require 'hanami/model'
require_relative '../lib/dontknowka'
require_relative '../apps/web/application'
require_relative '../apps/admin/application'
require_relative '../apps/events/application'

require "hanami/middleware/body_parser"

Hanami.configure do
  mount Events::Application, at: '/events'
  mount Admin::Application, at: '/admin'
  mount Web::Application, at: '/'

  ##
  # JSON parsing
  middleware.use Hanami::Middleware::BodyParser, :json

  model do
    ##
    # Database adapter
    #
    adapter :sql, ENV.fetch('DATABASE_URL')

    ##
    # Migrations
    #
    migrations 'db/migrations'
    schema     'db/schema.sql'
  end

  mailer do
    root 'lib/dontknowka/mailers'

    # See https://guides.hanamirb.org/mailers/delivery
    delivery :test
  end

  environment :development do
    # See: https://guides.hanamirb.org/projects/logging
    logger level: :debug
  end

  environment :production do
    logger level: :info, formatter: :json, filter: []

    mailer do
      delivery :smtp, address: ENV.fetch('SMTP_HOST'), port: ENV.fetch('SMTP_PORT')
    end
  end
end

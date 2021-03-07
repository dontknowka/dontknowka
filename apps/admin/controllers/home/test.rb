require 'rack'

def compare(a, b)
  Rack::Utils.secure_compare(a, b)
end

module Admin
  module Controllers
    module Home
      class Test
        include Admin::Action

        accept :json
        before :test_before

        def call(params)
          Hanami.logger.debug params.to_h.to_s
          redirect_to routes.root_path
        end

        private

        def test_before
          Hanami.logger.debug "Before: #{request.body.read}"
          Hanami.logger.debug compare('foo', request.env['HTTP_X_HUB_SIGNATURE_256'])
        end

        def verify_csrf_token?
          false
        end

        def authenticate?
        end
      end
    end
  end
end

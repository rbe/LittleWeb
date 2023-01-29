# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Dispatcher
  module Dispatcher
    require_relative 'abstract_dispatcher'

    # Dispatch request to proxy controller
    class SimpleProxyDispatcher < AbstractDispatcher
      require_relative '../controller/simple_proxy_controller'

      def dispatch_http_get
        return @response.forbidden_response "Invalid token for access to #{file}" unless check_file_access token

        SimpleProxyController.new(@cgi).process
      end

      private

      def check_file_access(token)
        token.valid? @request.request_uri
      end
    end
  end
end

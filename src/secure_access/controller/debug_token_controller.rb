# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Controller
  module Controller
    require_relative '../../http/controller'

    # Show token
    class DebugTokenController < HTTP::Controller
      def process
        token = @request[:token]
        add_message 'No sx_token' unless token
        bindings = {
          token:,
          file: @request.request_uri,
          request: ENV.inspect,
          message: @messages.join('<br/>')
        }
        render_view 'controller/views/debug_token.slim', bindings
      end
    end
  end
end

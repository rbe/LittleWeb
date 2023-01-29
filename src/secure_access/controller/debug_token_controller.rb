# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Controller
  module Controller
    require_relative '../../http/controller'

    # Show token
    class DebugTokenController < HTTP::Controller
      def render
        add_message 'No sx_token' unless @token
        @token = (SxToken.new.from_cookie @request.cookie_value('sx_token') if @request.query_value?('sx_token'))
        bindings = {
          token: @token,
          file: @request.request_uri,
          request: ENV.inspect,
          message: @messages.join('<br/>')
        }
        render_view 'views/debug_token.slim', bindings
      end
    end
  end
end

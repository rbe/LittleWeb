# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  require_relative '../http/controller'

  # Show token
  class DebugTokenController < HTTP::Controller
    def initialize(cgi)
      super(cgi)
      @token = (Token.new.from_cookie @request.cookie_value('sx_token') if @request.query_value?('sx_token'))
      @file = @request.request_uri
    end

    def render
      add_message 'No sx_token' unless @token
      bindings = {
        token: @token,
        file: @file,
        message: @messages.join('<br/>')
      }
      render_view 'views/debug_token.slim', bindings
    end
  end
end

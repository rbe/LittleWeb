# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  require_relative '../../http/controller'

  # Dispatcher
  module Dispatcher
    # Dispatcher base
    class AbstractDispatcher < HTTP::Controller
      def dispatch
        raise NotImplementedError
      end

      def csrf_token_is_valid?
        csrf_token_value = @request.query_value '__csrf_token'
        csrf_token = HTTP::CsrfToken.new csrf_token_value
        csrf_token.valid?
      end

      def handle_error(exception)
        backtrace = exception.backtrace&.join('<br/>')
        @cgi.out { "<p>Error: #{exception}</p><p>#{backtrace}</p>" }
        p exception.backtrace
      end
    end
  end
end

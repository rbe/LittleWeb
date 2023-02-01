# frozen_string_literal: true

# HTTP
module HTTP
  # Dispatcher
  module Dispatcher
    def handle_error(exception)
      backtrace = exception.backtrace&.join('<br/>')
      @response.server_error "<p>Error: #{exception}</p><p>#{backtrace}</p>"
      p exception.backtrace
    end
  end
end

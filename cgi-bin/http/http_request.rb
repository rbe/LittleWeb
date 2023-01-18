# frozen_string_literal: true

# HTTP
module HTTP
  # Helper for HTTP requests
  class HttpRequest
    def initialize(cgi)
      @cgi = cgi
    end

    # @param [String] name
    def cookie_value(name)
      @cgi.cookies[name].value.to_s.split(';')[0].split('=')[1]
    end
  end
end

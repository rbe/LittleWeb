#!/usr/bin/env ruby
# frozen_string_literal: true

# Tools for dealing with HTTP
module HTTP
  STD_HEADERS = {
    # 'nph' => true,
    'server' => 'RRS 1.0',
    'type' => 'text/plain',
    'charset' => 'UTF-8',
    'connection' => 'close'
  }.freeze

  # Helper for HTTP responses
  class HttpResponse
    def initialize(cgi)
      @cgi = cgi
    end

    # Send HTTP 200 OK response with cookie
    def success_response(cookies, body)
      headers = HTTP::STD_HEADERS.merge('status' => 200, 'cookie' => cookies)
      @cgi.out(headers) { body.to_s }
    end
    alias http200 success_response

    # Send HTTP 302 Temporary Redirect response with cookie
    def redirect_with_cookie_response(cookies, url)
      headers = HTTP::STD_HEADERS.merge('status' => 302, 'cookie' => cookies,
                                        'Location' => url)
      @cgi.out(headers) { '' }
    end

    # Send HTTP 403 Forbidden
    def error_reponse(error_message)
      headers = HTTP::STD_HEADERS.merge('status' => 403)
      @cgi.out(headers) { error_message.to_s }
    end

    # Send HTTP 404 Not Found
    def notfound_response
      headers = HTTP::STD_HEADERS.merge('status' => 404)
      @cgi.out(headers) { 'Uh?' }
    end

    # Send HTTP 405 Method Not Allowed
    def method_not_allowed_response
      headers = HTTP::STD_HEADERS.merge('status' => 405)
      @cgi.out(headers) { 'Uh?' }
    end
  end
end

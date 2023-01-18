# frozen_string_literal: true

# HTTP
module HTTP
  # Helper for HTTP responses
  class HttpResponse
    # Standard HTTP response headers
    STD_HEADERS = {
      # 'nph' => true,
      'server' => 'RRS 1.0',
      'type' => 'text/plain',
      'charset' => 'UTF-8',
      'connection' => 'close'
    }.freeze

    def initialize(cgi)
      @cgi = cgi
    end

    # @param [String] name Cookie name
    # @param [String] value Cookie value
    def self.create_cookie(name, value, std = {})
      CGI::Cookie.new(
        std.merge(
          {
            'name' => name,
            'path' => '/',
            'value' => value
          }
        )
      )
    end

    # Send HTTP 200 OK response
    # @param [String] body
    def success_response(body)
      headers = STD_HEADERS.merge('status' => 200)
      @cgi.out(headers) { body.to_s }
    end

    # Send HTTP 200 OK response with cookie
    def success_response_with_cookie(cookies, body)
      headers = STD_HEADERS.merge('status' => 200, 'cookie' => cookies)
      @cgi.out(headers) { body.to_s }
    end

    # Send HTTP 302 Temporary Redirect response with cookie
    # @param [Array] cookies
    # @param [String] url
    def redirect_with_cookie_response(cookies, url)
      headers = STD_HEADERS.merge('status' => 302, 'cookie' => cookies,
                                  'Location' => url)
      @cgi.out(headers) { '' }
    end

    # Send HTTP 400 Bad Request
    # @param [String] message
    def bad_request_response(message = '')
      headers = STD_HEADERS.merge('status' => 400)
      @cgi.out(headers) { message.to_s }
    end

    # Send HTTP 403 Forbidden
    # @param [String] message
    def forbidden_reponse(message = '')
      headers = STD_HEADERS.merge('status' => 403)
      @cgi.out(headers) { message.to_s }
    end

    # Send HTTP 404 Not Found
    def notfound_response
      headers = STD_HEADERS.merge('status' => 404)
      @cgi.out(headers) { 'Not found' }
    end

    # Send HTTP 405 Method Not Allowed
    def method_not_allowed_response
      headers = STD_HEADERS.merge('status' => 405)
      @cgi.out(headers) { 'Method not allowed' }
    end
  end
end

# frozen_string_literal: true

# HTTP
module HTTP
  # Helper for HTTP responses
  class HttpResponse
    require 'cgi'
    require 'securerandom'

    CSP_NONCE = "nonce-#{SecureRandom.alphanumeric}".freeze

    # Standard HTTP response headers
    STD_HEADERS = {
      # 'nph' => true,
      'server' => 'RRS 1.0',
      'type' => 'text/plain',
      'charset' => 'UTF-8',
      'connection' => 'close',
      'content-filter-policy' => "default-src 'none';" \
        " script-src 'self' '#{CSP_NONCE}';" \
        " connect-src 'self';" \
        " img-src 'self' data:;" \
        " style-src 'self' '#{CSP_NONCE}';" \
        " font-src 'self';" \
        " base-uri 'self';"\
        " form-action 'self'"
    }.freeze

    attr_accessor :response_written

    def initialize(cgi)
      @cgi = cgi
      @response_written = false
    end

    # @param [String] name Cookie name
    # @param [String] value Cookie value
    # @param [Hash] std Cookie value
    def self.create_cookie(name, value, std = {})
      values = std.merge({
                           'name' => name,
                           'path' => '/',
                           'value' => value
                         })
      CGI::Cookie.new(values)
    end

    # Send HTTP 200 OK response (with cookie)
    # @param [String] body
    # @param [String] content_type
    # @param [Array<CGI::Cookie>] cookies
    def success(body, content_type = 'text/html', cookies = [])
      raise 'Response already written' if @response_written

      headers = STD_HEADERS.merge('type' => content_type, 'status' => 200, 'cookie' => cookies)
      @cgi.out(headers) { body.to_s }
      @response_written = true
    end

    # Send HTTP 302 Temporary Redirect response with cookie
    # @param [String] url
    # @param [Array<CGI::Cookie>] cookies
    def redirect(url, cookies = [])
      raise 'Response already written' if @response_written

      headers = STD_HEADERS.merge('status' => 302, 'cookie' => cookies,
                                  'Location' => url)
      @cgi.out(headers) { '' }
      @response_written = true
    end

    # Send HTTP 400 Bad Request
    # @param [String] message
    def bad_request(message = 'Bad request')
      raise 'Response already written' if @response_written

      headers = STD_HEADERS.merge('status' => 400, 'cookie' => reset_cookies)
      @cgi.out(headers) { message.to_s }
      @response_written = true
    end

    # Send HTTP 403 Forbidden
    # @param [String] message
    def forbidden(message = '')
      raise 'Response already written' if @response_written

      headers = STD_HEADERS.merge('status' => 403, 'cookie' => reset_cookies)
      @cgi.out(headers) { message.to_s }
      @response_written = true
    end

    # Send HTTP 404 Not Found
    def not_found(message = 'Not found')
      raise 'Response already written' if @response_written

      headers = STD_HEADERS.merge('status' => 404)
      @cgi.out(headers) { message }
      @response_written = true
    end

    # Send HTTP 405 Method Not Allowed
    def method_not_allowed(message = 'Method not allowed')
      raise 'Response already written' if @response_written

      headers = STD_HEADERS.merge('status' => 405, 'cookie' => reset_cookies)
      @cgi.out(headers) { message }
      @response_written = true
    end

    # Send HTTP 500 Internal Server Error
    def server_error(message = '')
      raise 'Response already written' if @response_written

      headers = STD_HEADERS.merge('status' => 500, 'cookie' => reset_cookies)
      @cgi.out(headers) { message }
      @response_written = true
    end

    private

    def reset_cookies
      values = {
        'path' => '/',
        'expires' => Time.at(0)
      }
      [
        CGI::Cookie.new({ 'name' => 'sx_token' }.merge(values)).to_s,
        CGI::Cookie.new({ 'name' => 'sx_hash' }.merge(values)).to_s
      ]
    end
  end
end

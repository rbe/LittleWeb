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
      'content-security-policy' => "default-src 'none';" \
        " script-src 'self' '#{CSP_NONCE}';" \
        " connect-src 'self';" \
        " img-src 'self' data:;" \
        " style-src 'self' '#{CSP_NONCE}';" \
        " font-src 'self';" \
        " base-uri 'self';"\
        " form-action 'self'"
    }.freeze

    def initialize(cgi)
      @cgi = cgi
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

    # Send HTTP 200 OK response
    # @param [String] body
    def success_response(body)
      headers = STD_HEADERS.merge('type' => 'text/html', 'status' => 200)
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
      headers = STD_HEADERS.merge('status' => 400, 'cookie' => reset_cookies)
      @cgi.out(headers) { message.to_s }
    end

    # Send HTTP 403 Forbidden
    # @param [String] message
    def forbidden_response(message = '')
      headers = STD_HEADERS.merge('status' => 403, 'cookie' => reset_cookies)
      @cgi.out(headers) { message.to_s }
    end

    # Send HTTP 404 Not Found
    def notfound_response
      headers = STD_HEADERS.merge('status' => 404)
      @cgi.out(headers) { 'Not found' }
    end

    # Send HTTP 405 Method Not Allowed
    def method_not_allowed_response
      headers = STD_HEADERS.merge('status' => 405, 'cookie' => reset_cookies)
      @cgi.out(headers) { 'Method not allowed' }
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

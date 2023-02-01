# frozen_string_literal: true

# HTTP
module HTTP
  # Helper for HTTP requests
  class HttpRequest
    attr_reader :request_scheme, :http_host, :request_method,
                :request_uri, :original_request_uri,
                :query_string

    def initialize(cgi)
      @cgi = cgi
      @request_scheme = ENV['REQUEST_SCHEME'].strip
      @http_host = ENV['HTTP_HOST'].strip
      @request_method = ENV['REQUEST_METHOD'].strip
      @request_uri = sanitize ENV['REQUEST_URI'].strip, ['?']
      @query_string = sanitize ENV['QUERY_STRING'], ['&']
      @extra = {}
    end

    def http_get?
      @request_method == 'GET'
    end

    def http_post?
      @request_method == 'POST'
    end

    def http_host_only
      @http_host.split(':')[0]
    end

    # @param [Array<String>] names
    def query_value?(*names)
      names.all? { |e| @cgi.params.key?(e) && !@cgi.params[e][0].empty? }
    end

    # @param [String] name
    def query_value(name)
      return unless @cgi.params.key? name

      values = @cgi.params[name]
      sanitize values[0]
    end

    # @param [Array<String>] names
    def cookie_value?(*names)
      names.all? { |e| @cgi.cookies.key?(e) && !@cgi.cookies[e].empty? }
    end

    # @param [String] name
    def cookie_value(name)
      return unless @cgi.cookies.key? name

      value = @cgi.cookies[name].value
      fields = value.to_s.split(';')
      kv = fields[0].split('=')
      sanitize kv[1]
    end

    def [](key)
      @extra[key]
    end

    def []=(key, value)
      @extra[key] = value
    end

    def modify(method:, uri:)
      modify_request_method method
      modify_request_uri uri
    end

    def modify_request_method(new_request_method)
      @request_method = new_request_method
    end

    def modify_request_uri(new_request_uri)
      @original_request_uri = @request_uri
      @request_uri = new_request_uri
    end

    class << self
      def test_cookie_value?
        require 'cgi'
        ENV['REQUEST_METHOD'] = 'GET'
        ENV['REQUEST_URI'] = '/bla'
        ENV['QUERY_STRING'] = 'user=ralf%40bensmann.com'
        p HTTP::HttpRequest.new(CGI.new).cookie_value? 'a'
      end
    end

    private

    # @param [String] str
    # @param [Array] extra_chars
    def sanitize(str, extra_chars = [])
      return unless str

      ords = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890+-,.-_=/@'.chars.map(&:ord)
      extra_ords = extra_chars.map(&:ord)
      str.codepoints.filter { |e| ords.include?(e) || extra_ords.include?(e) }.map(&:chr).join('')
    end
  end
end

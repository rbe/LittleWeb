# frozen_string_literal: true

# HTTP
module HTTP
  # Helper for HTTP requests
  class HttpRequest
    def initialize(cgi)
      @cgi = cgi
    end

    def request_uri
      '' unless ENV.key? 'REQUEST_URI'
      url = ENV['REQUEST_URI'].strip
      sanitize url
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
      ords = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890+-,.-_=/@'.chars.map(&:ord)
      extra_ords = extra_chars.map(&:ord)
      str.codepoints.filter { |e| ords.include?(e) || extra_ords.include?(e) }.map(&:chr).join('')
    end
  end
end

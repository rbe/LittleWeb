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
      url.ascii_only? ? url : ''
    end

    # @param [String] names
    def query_value?(*names)
      names.all? { |e| @cgi.params.key? e }
    end

    # @param [String] name
    def query_value(name)
      return unless @cgi.params.key? name

      values = @cgi.params[name]
      values[0].strip
    end

    # @param [String] names
    def cookie_value?(*names)
      names.all? { |e| @cgi.cookies.key? e }
    end

    # @param [String] name
    def cookie_value(name)
      return unless @cgi.cookies.key? name

      value = @cgi.cookies[name].value
      fields = value.to_s.split(';')
      kv = fields[0].split('=')
      kv[1]
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
  end
end

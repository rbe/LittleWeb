# frozen_string_literal: true

# HTTP
module HTTP
  # MVC - Controller
  class Controller
    require 'cgi'
    require 'cgi/core'
    require 'cgi/cookie'
    require_relative 'http_request'
    require_relative 'http_response'

    attr_reader :messages

    # @param [CGI] cgi
    def initialize(cgi)
      @cgi = cgi
      @request = HTTP::HttpRequest.new(cgi)
      @response = HTTP::HttpResponse.new(cgi)
      @messages = []
    end

    # @param [String] text
    def add_message(text)
      @messages << text
    end

    # @param [String] file
    # @param [Hash] bindings
    # @return [String] Value of @cgi.out
    def render_view(file, bindings = {})
      template = Slim::Template.new file
      content = template.render self, bindings
      @response.success_response content
    end

    # @param [String] file
    # @param [Hash] bindings
    # @return [String] Rendered template
    def render_template(file, bindings = {})
      template = Slim::Template.new file
      template.render self, bindings
    end
  end
end

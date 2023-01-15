#!/usr/bin/env ruby
# frozen_string_literal: true

# Provide secure access to resources
module SecureAccess
  require './secure_access'

  # CGI
  class Dispatcher < HTTP::HttpResponse
    require 'cgi/core'
    require 'cgi/cookie'

    def initialize
      @cgi = CGI.new('html5')
      super(@cgi)
    end

    # Dispatch HTTP request
    def dispatch
      case ENV['REQUEST_METHOD']
      when 'GET'
        dispatch_http_get
      when 'POST'
        dispatch_http_post
      else
        method_not_allowed_response
      end
    end

    private

    SECURE_LINK_TXT = 'secure_link.txt'

    # Dispatch HTTP GET
    def dispatch_http_get
      case ENV['SCRIPT_NAME']
      when %r{.+/get_access$}
        SecureLinkRequestForm.new(@cgi).render
      else
        notfound_response
      end
    end

    # Dispatch HTTP POST
    def dispatch_http_post
      case ENV['SCRIPT_NAME']
      when %r{.+/get_access$}
        dispatch_http_post_get_access
      else
        notfound_response
      end
    end

    # Dispatch HTTP GET /get_access
    def dispatch_http_post_get_access
      user = @cgi['user']
      url = @cgi['url']
      if check_access user, url
        SecureLinkRequestForm.new(@cgi).process
      else
        error_reponse('No access')
      end
    end

    # Check if a user has access
    def check_access(user, url)
      if File.exist?(SECURE_LINK_TXT)
        lines = File.read(SECURE_LINK_TXT).split
        grep = lines.grep(/^#{url}:#{user}/)
        grep.length == 1
      else
        false
      end
    end
  end
end

SecureAccess::Dispatcher.new.dispatch

#!/usr/bin/env ruby
# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  require_relative '../http/http_request'
  require_relative '../http/http_response'
  require_relative 'constants'

  # CGI
  class Dispatcher < HTTP::HttpResponse
    require 'cgi/core'
    require 'cgi/cookie'
    require_relative 'link_request_form'
    require_relative 'token'
    require_relative 'simple_proxy'

    def initialize
      @cgi = CGI.new('html5')
      super(@cgi)
      @request = HTTP::HttpRequest.new(@cgi)
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
      # rescue StandardError => e
      # @cgi.out { "Error: #{e}<br/>#{e.backtrace.join('<br/>')}" }
    end

    private

    # Dispatch HTTP GET
    def dispatch_http_get
      case ENV['REQUEST_URI']
      when %r{#{Constants::URL_PREFIX}/$}
        LinkRequestForm.new(@cgi).render_form
      when %r{.+/sx_request$}
        LinkRequestForm.new(@cgi).render_form
      when %r{.+/sx_exchange\?token=.+&hash=.+$}
        b64link_to_cookie
      when %r{/debug}
        debug_token
      else
        proxy_request
      end
    end

    def debug_token
      if @cgi.cookies.key?('sx_token')
        token = Token.new.from_cookie @cgi.cookies['sx_token']
        file = ENV['REQUEST_URI']
        @cgi.out do
          "Token #{token},<br/>" \
          "user #{token.user}, URL #{token.url}<br>" \
          "expires #{token.expires.to_i}/#{token.expires} > (#{Time.now.to_i}/#{Time.now}) -> timed_out? #{token.timed_out?}<br/>" \
          "File #{file} -> #{token.access? token.user, file}<br>" \
          "-> #{token.valid? file}"
        end
      else
        @cgi.out { 'No token' }
      end
    end

    def b64link_to_cookie
      token = Token.new.from_s @cgi['token']
      hash = @cgi['hash']
      forbidden_reponse 'Hash invalid' unless token == hash
      bad_request_response 'Something went wrong' unless redirect_with_cookie_response(token.bake_cookies, token.url)
    end

    def proxy_request
      return bad_request_response 'No token' unless @cgi.cookies.key?('sx_token')

      token = Token.new.from_cookie @cgi.cookies['sx_token']
      hash = @request.cookie_value 'sx_hash'
      return forbidden_reponse 'Hash invalid' unless token == hash

      file = ENV['REQUEST_URI']
      return forbidden_reponse "No access to #{file}" unless token.valid? file

      SimpleProxy.new(@cgi).get_file(file)
    end

    # Dispatch HTTP POST
    def dispatch_http_post
      case ENV['REQUEST_URI']
      when %r{#{Constants::URL_PREFIX}/$}
        dispatch_http_post_sx_access
      when %r{.+/sx_request$}
        dispatch_http_post_sx_access
      else
        notfound_response
      end
    end

    # Dispatch HTTP GET /sx_access
    def dispatch_http_post_sx_access
      user = @cgi['user']
      url = @cgi['url']
      if user && url
        LinkRequestForm.new(@cgi).process_form
      else
        forbidden_reponse 'Invalid request'
      end
    end
  end
end

SecureAccess::Dispatcher.new.dispatch

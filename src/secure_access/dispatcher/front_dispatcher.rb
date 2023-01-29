#!/usr/bin/env ruby
# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Dispatcher
  module Dispatcher
    require_relative 'abstract_dispatcher'

    # Front dispatcher
    class FrontDispatcher < AbstractDispatcher
      require_relative 'otp_dispatcher'
      require_relative 'simple_proxy_dispatcher'
      require_relative '../controller/tkx_controller'
      require_relative '../controller/access_request_controller'
      require_relative '../controller/debug_token_controller'

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
          @response.method_not_allowed_response
        end
      rescue StandardError => e
        handle_error(e)
      end

      private

      # Dispatch HTTP GET
      def dispatch_http_get
        case @request.request_uri
        when %r{.+/sx/otp/.+$}
          OtpDispatcher.new(@cgi).dispatch_http_get
        when %r{.+/sx/tkx\?token=.+&hash=.+$}
          Controller::TkxController.new(@cgi).render
        when %r{.+/sx.*}
          @response.notfound_response
        when %r{/debug_.+}
          Controller::DebugTokenController.new(@cgi).render
        else
          return @response.forbidden_response 'Invalid token or hash' unless check_sx_token

          SimpleProxyDispatcher.new(@cgi).dispatch_http_get
        end
      end

      # Dispatch HTTP POST
      def dispatch_http_post
        return @response.bad_request_response 'CSRF token invalid' unless csrf_token_is_valid?
        return @response.bad_request_response if @request.query_value? 'username'

        case @request.request_uri
        when %r{.+/sx/otp/.+$}
          OtpDispatcher.new(@cgi).dispatch_http_post
        else
          Controller::AccessRequestController.new(@cgi).process
        end
      end

      def check_sx_token
        return Controller::AccessRequestController.new(@cgi).render \
          unless @request.cookie_value?('sx_token', 'sx_hash')

        token = Authentication::SxToken.new.from_cookie @request.cookie_value('sx_token')
        hash = @request.cookie_value 'sx_hash'
        return false unless token == hash

        true
      end

      class << self
        def test
          ENV['REQUEST_METHOD'] = 'GET'
          ENV['REQUEST_URI'] = '/Gallimaufry/sx/otp/registration'
          FrontDispatcher.new.dispatch
        end
      end
    end
  end
end

SecureAccess::Dispatcher::FrontDispatcher.new.dispatch
# SecureAccess::Dispatcher::FrontDispatcher.test

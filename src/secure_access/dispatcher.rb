#!/usr/bin/env ruby
# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  require_relative '../http/controller'
  require_relative 'constants'

  # CGI
  class Dispatcher < HTTP::Controller
    require_relative 'token'
    require_relative 'otp_registration_controller'
    require_relative 'access_request_controller'
    require_relative 'link_to_cookie_controller'
    require_relative 'simple_proxy_controller'
    require_relative 'debug_token_controller'

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

    def handle_error(exception)
      backtrace = exception.backtrace&.join('<br/>')
      @cgi.out { "<p>Error: #{exception}</p><p>#{backtrace}</p>" }
      p exception.backtrace
    end

    # Dispatch HTTP GET
    def dispatch_http_get
      case @request.request_uri
      when %r{.+/sx_otp_registration$}
        OtpRegistrationController.new(@cgi).render_registration_form
      when %r{.+/sx_exchange\?token=.+&hash=.+$}
        LinkToCookieController.new(@cgi).render
      when %r{.+/sx.*}
        @response.method_not_allowed_response
      when %r{/debug_token}
        DebugTokenController.new(@cgi).render
      when %r{/debug_request}
        @cgi.out { ENV.inspect }
      else
        dispatch_proxy
      end
    end

    def dispatch_proxy
      return @response.forbidden_response 'Invalid token or hash' unless check_sx_token
      return @response.forbidden_response "Invalid token for access to #{file}" unless check_file_access(token)

      SimpleProxyController.new(@cgi).process
    end

    # Dispatch HTTP POST
    def dispatch_http_post
      return @response.bad_request_response('CSRF token invalid') unless csrf_token_is_valid?

      case @request.request_uri
      when %r{.+/sx_otp_registration$}
        dispatch_otp_registration
      when %r{.+/sx_check_otp$}
        CheckOtpController.new(@cgi).process
      else
        AccessRequestController.new(@cgi).process
      end
    end

    def dispatch_otp_registration
      controller = OtpRegistrationController.new(@cgi)
      if @request.query_value? 'otp_code'
        controller.process_qrcode_form
      else
        controller.process_registration_form
      end
    end

    def check_sx_token
      return AccessRequestController.new(@cgi).render \
        unless @request.cookie_value?('sx_token', 'sx_hash')

      token = Token.new.from_cookie @request.cookie_value('sx_token')
      hash = @request.cookie_value 'sx_hash'
      return false unless token == hash

      true
    end

    def check_file_access(token)
      token.valid? @request.request_uri
    end

    def csrf_token_is_valid?
      csrf_token_value = @request.query_value '__csrf_token'
      csrf_token = HTTP::CsrfToken.new csrf_token_value
      csrf_token.valid?
    end

    class << self
      def test
        ENV['REQUEST_METHOD'] = 'POST'
        ENV['CONTENT_LENGTH'] = '0'
        ENV['REQUEST_URI'] = '/Gallimaufry/IJOS-Stellenportal/IJOS-Stellenportal.adoc'
        ENV['QUERY_STRING'] = 'user=ralf%40bensmann.com'
      end
    end
  end
end

SecureAccess::Dispatcher.new.dispatch

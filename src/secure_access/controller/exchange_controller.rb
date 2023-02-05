# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Controller
  module Controller
    require_relative '../../http/controller'

    # Exchange link with token and hash to cookies
    # Perform 2FA through OTP
    class ExchangeController < HTTP::Controller
      require_relative '../../authentication/sx_token'
      require_relative '../../authentication/totp'

      def processable?
        @response.bad_request 'No token' unless @request.query_value? 'token', 'hash'
        token = Authentication::SxToken.new.from_s @request.query_value 'token'
        hash = @request.query_value 'hash'
        @response.bad_request 'Invalid token' unless token === hash
      end

      def process
        case @request.request_method
        when 'GET'
          render_otp_form
        when 'POST'
          process_exchange_with_otp_code
        else
          @response.method_not_allowed
        end
      end

      private

      def render_otp_form
        token = @request.query_value 'token'
        hash = @request.query_value 'hash'
        bindings = {
          '__csrf_token': HTTP::CsrfToken.new,
          token:,
          hash:,
          message: messages_as_html
        }
        render_view 'controller/views/exchange_form.slim', bindings
      end

      def process_exchange_with_otp_code
        ok = Authentication::TOTP.new.verify @request.query_value('user'),
                                             @request.query_value('otp_code')
        return @response.bad_request 'Bad OTP' unless ok

        hash = @request.query_value 'hash'
        token = Authentication::SxToken.new.from_s @request.query_value 'token'
        unless token === hash && @response.redirect(token.url, token.bake_cookies(@request))
          @response.bad_request 'Something went wrong'
        end
      end
    end
  end
end

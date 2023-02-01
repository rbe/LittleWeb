# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Controller
  module Controller
    require_relative '../../http/controller'

    # Exchange link with token and hash to cookies
    # Perform 2FA through TOTP
    class ExchangeController < HTTP::Controller
      require_relative '../../authentication/sx_token'
      require_relative '../../authentication/totp'

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
        check_exchange
        bindings = {
          '__csrf_token': HTTP::CsrfToken.new,
          token: @token,
          hash: @hash,
          message: @messages.join('<br/>')
        }
        render_view 'controller/views/exchange_form.slim', bindings
      end

      def process_exchange_with_otp_code
        return @response.bad_request 'Missing token, hash' unless @request.query_value? 'token', 'hash'

        check_exchange
        bad_request 'Something went wrong' unless @response.redirect(@token.url, @token.bake_cookies(@request))
      end

      def check_exchange
        @token = Authentication::SxToken.new.from_s @request.query_value('token')
        return @response.bad_request 'No token' unless @token

        @hash = @request.query_value('hash')
        @response.bad_request 'Invalid token or hash' unless @token == @hash
      end
    end
  end
end

# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Controller
  module Controller
    require_relative '../../http/controller'

    # Exchange link with token and hash to cookies
    # Perform 2FA through TOTP
    class TkxController < HTTP::Controller
      require_relative '../../authentication/totp'

      def render
        check_sx_token
        bindings = {
          '__csrf_token': HTTP::CsrfToken.new,
          token: @token,
          hash: @hash,
          message: @messages.join('<br/>')
        }
        render_view 'views/link_to_cookie_form.slim', bindings
      end

      def process
        return @response.bad_request_response 'Missing token, hash' unless @request.query_value? 'token', 'hash'

        check_sx_token
        bad_request_response 'Something went wrong' \
        unless @response.redirect_with_cookie_response(token.bake_cookies, token.url)
      end

      def check_sx_token
        @token = SxToken.new.from_s @request.query_value('token')
        return @response.bad_request_response 'No token' \
        unless @token

        @hash = @request.query_value('hash')
        @response.bad_request_response 'Invalid token or hash' \
        unless @token == @hash
      end
    end
  end
end

# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Controller
  module Controller
    require_relative '../../http/controller'

    # Exchange link with token and hash to cookies
    # Perform 2FA through TOTP
    class OtpRegistrationController < HTTP::Controller
      require_relative '../../http/csrf_token'
      require_relative '../../authentication/totp'

      def render_registration_form
        bindings = {
          __csrf_token: HTTP::CsrfToken.new,
          message: @messages.join('<br/>')
        }
        render_view 'views/otp_registration_form.slim', bindings
      end

      def render_qrcode_form
        user = @request.query_value 'user'
        qrcode = Authentication::TOTP.new.generate_qrcode user
        otp_svg = Base64.strict_encode64 qrcode
        bindings = {
          __csrf_token: HTTP::CsrfToken.new,
          user:,
          otp_svg:,
          message: @messages.join('<br/>')
        }
        render_view 'views/otp_registration_qrcode_form.slim', bindings
      end

      def process_registration_form
        bindings = {
          __csrf_token: HTTP::CsrfToken.new,
          url: @request.request_uri,
          user: @request.query_value('user'),
          message: @messages.join('<br/>')
        }
        render_view 'views/otp_registration_qrcode_form.slim', bindings
      end

      def process_qrcode_form
        ok = Authentication::TOTP.new.verify_first_time @request.query_value('user'),
                                                        @request.query_value('otp_code')
        bindings = {
          user: @request.query_value('user'),
          message: @messages.join('<br/>')
        }
        if ok
          render_view 'views/otp_registration_success.slim', bindings
        else
          render_view 'views/otp_registration_error.slim', bindings
        end
      end
    end
  end
end

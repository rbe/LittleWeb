# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Controller
  module Controller
    require_relative '../../http/controller'

    # Exchange link with token and hash to cookies
    # Perform 2FA through TOTP
    class OtpRegistrationController < HTTP::Controller
      require_relative '../../authentication/totp'

      def process
        case @request.request_method
        when 'GET'
          process_http_get
        when 'POST'
          process_http_post
        else
          @response.method_not_allowed
        end
      end

      private

      def process_http_get
        if @request.query_value?('user')
          render_qrcode_form
        else
          render_registration_form
        end
      end

      def process_http_post
        if @request.query_value?('user', 'otp_code')
          process_qrcode_form
        elsif @request.query_value?('user')
          render_qrcode_form
        end
      end

      def render_registration_form
        bindings = {
          __csrf_token: HTTP::CsrfToken.new,
          message: messages_as_html
        }
        render_view 'controller/views/otp_registration_form.slim', bindings
      end

      def render_qrcode_form
        user = @request.query_value 'user'
        qrcode = Authentication::TOTP.new.generate_qrcode user
        otp_svg = Base64.strict_encode64 qrcode
        bindings = {
          __csrf_token: HTTP::CsrfToken.new,
          user:,
          otp_svg:,
          message: messages_as_html
        }
        render_view 'controller/views/otp_registration_qrcode_form.slim', bindings
      end

      def process_qrcode_form
        ok = Authentication::TOTP.new.verify_first_time @request.query_value('user'),
                                                        @request.query_value('otp_code')
        bindings = {
          user: @request.query_value('user'),
          message: messages_as_html
        }
        if ok
          render_view 'controller/views/otp_registration_success.slim', bindings
        else
          render_view 'controller/views/otp_registration_error.slim', bindings
        end
      end
    end
  end
end

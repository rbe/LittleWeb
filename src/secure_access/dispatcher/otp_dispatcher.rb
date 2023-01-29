# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Dispatcher
  module Dispatcher
    require_relative 'abstract_dispatcher'

    # CGI
    class OtpDispatcher < AbstractDispatcher
      require_relative '../../authentication/sx_token'
      require_relative '../controller/otp_registration_controller'

      # Dispatch HTTP GET
      def dispatch_http_get
        case @request.request_uri
        when %r{.+/sx/otp/registration$}
          Controller::OtpRegistrationController.new(@cgi).render_registration_form
        else
          @response.notfound_response
        end
      end

      # Dispatch HTTP POST
      def dispatch_http_post
        case @request.request_uri
        when %r{.+/sx/otp/registration$}
          dispatch_otp_registration
        when %r{.+/sx/otp/check$}
          Controller::CheckOtpController.new(@cgi).process
        else
          @response.notfound_response
        end
      end

      private

      def dispatch_otp_registration
        controller = Controller::OtpRegistrationController.new(@cgi)
        if @request.query_value? 'user', 'otp_code'
          controller.process_qrcode_form
        elsif @request.query_value? 'user'
          controller.render_qrcode_form
        else
          controller.process_registration_form
        end
      end
    end
  end
end

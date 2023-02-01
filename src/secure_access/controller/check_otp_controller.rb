# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Controller
  module Controller
    require_relative '../../http/controller'

    # Check an OTP token
    class CheckOtpController < HTTP::Controller
      require_relative '../../authentication/totp'

      def process
        unless @request.query_value? 'token', 'hash', 'otp_code'
          return @response.bad_request('Missing request data')
        end

        token = @request.query_value 'token'
        hash = @request.query_value 'hash'
        otp_code = @request.query_value 'otp_code'
        return @response.bad_request 'TOTP invalid' unless Authentication::TOTP.new.verify user, otp_code

        @response.redirect()
      end
    end
  end
end

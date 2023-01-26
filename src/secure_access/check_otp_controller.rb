# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  require_relative '../http/controller'

  # Check an OTP token
  class CheckOtpController < HTTP::Controller
    require_relative '../authentication/totp'

    def process
      return @response.bad_request_response unless @request.query_value? 'token', 'hash', 'otp_code'

      token = @request.query_value 'token'
      hash = @request.query_value 'hash'
      otp_code = @request.query_value 'otp_code'
      return @response.bad_request_response 'TOTP invalid' unless Authentication::TOTP.new.verify user, otp_code

      @response.redirect_with_cookie_response()
    end
  end
end

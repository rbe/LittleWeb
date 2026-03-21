# frozen_string_literal: true

# OTP
module Authentication
  class Constants
    # 2 hours in seconds
    EXPIRE_IN_SECONDS = 2 * 60 * 60
    # Issuer of OTP token
    OTP_ISSUER = ENV['GM_OTP_ISSUER'] || 'example.com'
  end
end

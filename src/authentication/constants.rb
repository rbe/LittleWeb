# frozen_string_literal: true

# OTP
module Authentication
  class Constants
    # Issuer of OTP token
    OTP_ISSUER = ENV['GM_OTP_ISSUER'] || 'example.com'
  end
end

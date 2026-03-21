# frozen_string_literal: true

# OTP
module SecureAccess
  module HttpFilter
    class Constants
      # File with list of users having access to resources
      SECURE_LINK_TXT = ENV['GM_SECURE_LINK_TXT'] || '/db/secure_access.txt'
    end
  end
end

# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # HTTP request filter chain
  module HttpFilter
    # If someone put a hand on our honeypot...
    class HoneypotFilter
      def filter(request, response, chain)
        response.bad_request if request.query_value? 'username'
        chain.filter(request, response)
      end
    end
  end
end

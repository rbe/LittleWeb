# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # HTTP request filter chain
  module RequestFilter
    # If someone put a hand on our honeypot...
    class HoneypotFilter
      def filter(request, response, chain)
        if request.query_value? 'username'
          response.bad_request
        else
          chain.filter(request, response)
        end
      end
    end
  end
end

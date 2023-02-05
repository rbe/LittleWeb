# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # HTTP request filter chain
  module HttpFilter
    # Validate CSRF token (when is given in request)
    # There's no HTTP POST without a CSRF token
    class CsrfTokenFilter
      def filter(request, response, chain)
        if request.query_value?('__csrf_token') || request.http_post?
          csrf_token_value = request.query_value '__csrf_token'
          csrf_token = HTTP::CsrfToken.new csrf_token_value
          response.bad_request 'CSRF token invalid' unless csrf_token.valid?
        end
        chain.filter(request, response)
      end
    end
  end
end

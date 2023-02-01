# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # HTTP request filter chain
  module RequestFilter
    # Validate sx_token
    class AuthorizationFilter
      # @param [Array<Regex>] include_urls
      # @param [Array<Regex>] exclude_urls
      def initialize(include_urls = [], exclude_urls = [])
        @include_urls = include_urls
        @exclude_urls = exclude_urls
      end

      def filter(request, response, chain)
        chain.filter(request, response)
      end
    end
  end
end

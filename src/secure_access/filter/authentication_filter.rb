# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # HTTP request filter chain
  module RequestFilter
    # Validate sx_token
    class AuthenticationFilter
      # @param [Array<Regex>] include_urls
      # @param [Array<Regex>] exclude_urls
      def initialize(include_urls = [], exclude_urls = [])
        @include_urls = include_urls
        @exclude_urls = exclude_urls
      end

      def filter(request, response, chain)
        if excluded?(request)
          # Ignored
        elsif included?(request)
          if request.cookie_value?('sx_token', 'sx_hash')
            process_sx_cookies(request)
          else
            request.modify method: 'GET', uri: '/sx/access_request'
          end
        end
        chain.filter(request, response)
      end

      private

      def process_sx_cookies(request)
        token = Authentication::SxToken.new.from_cookie_value request.cookie_value('sx_token')
        hash = request.cookie_value 'sx_hash'
        if (token == hash) && token.valid?(request.request_uri)
          request[:token] = token
          request[:hash] = hash
        else
          request.modify method: 'GET', uri: '/sx/access_request'
        end
      end

      def included?(request)
        @include_urls.any? { |p| p.match?(request.request_uri) }
      end

      def excluded?(request)
        @exclude_urls.any? { |p| p.match?(request.request_uri) }
      end
    end
  end
end

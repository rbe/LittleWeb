# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # HTTP filter chain
  module HttpFilter
    # Validate sx_token
    class AuthorizationFilter
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
          if request.authenticated? && access?(request[:user], request.request_uri)
            request.authorize
          else
            request.unauthorize
          end
        end
        chain.filter(request, response)
      end

      private

      # Check if a user has access to an URL
      # @param [String] user
      # @param [String] url
      def access?(user, url)
        if File.exist? Constants::SECURE_LINK_TXT
          lines = File.read(Constants::SECURE_LINK_TXT).split
          exact_match(lines, url, user) || partly_match(lines, url, user)
        else
          false
        end
      end

      # @param [Array<String>] lines
      # @param [String] url
      # @param [String] user
      def partly_match(lines, url, user)
        found = false
        lines.each do |entry|
          entry = entry.split(':')
          if url.match(/#{entry}.*/) && user.match(/.*#{entry}$/)
            found = true
            break
          end
        end
        found
      end

      # @param [Array<String>] lines
      # @param [String] url
      # @param [String] user
      def exact_match(lines, url, user)
        grep = lines.grep(/^#{url}:#{user}/)
        grep.length == 1
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

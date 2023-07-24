# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Controller
  module Controller
    require_relative '../../http/controller'

    # Secure link request use case
    class AccessRequestController < HTTP::Controller
      require 'slim'
      require 'mail'
      require_relative '../../http/csrf_token'
      require_relative '../../authentication/sx_token'
      require_relative 'constants'

      def initialize(request, response)
        super(request, response)
        @mail = Mail.new do
          delivery_method :smtp,
                          address: Constants::EMAIL_HOST_FQDN,
                          port: Constants::EMAIL_HOST_PORT
          from Constants::EMAIL_FROM
        end
      end

      def processable?
        true
        # TODO ???
        #return true if @request.query_value? 'user'
        #
        #@response.redirect '/Gallimaufry/'
        #false
      end

      def process
        case @request.request_method
        when 'GET'
          render_token_request_form
        when 'POST'
          process_token_request
        else
          @response.method_not_allowed
        end
      end

      private

      # Show form to request access
      def render_token_request_form
        bindings = {
          '__csrf_token': HTTP::CsrfToken.new,
          url: @request.original_request_uri,
          message: messages_as_html
        }
        render_view 'controller/views/access_request_form.slim', bindings
      end

      def process_token_request
        token = create_sx_token
        return @response.forbidden messages_as_html unless token

        user = validate_user
        url = validate_url
        html = access_granted_email url, token
        send_mail_and_response user, url, html
      end

      def create_sx_token
        user = validate_user
        url = validate_url
        return if user.nil_or_empty? || url.nil_or_empty?

        Authentication::SxToken.new.with user, url
      end

      def validate_url
        url = @request.query_value 'url'
        unless url =~ %r{[A-Za-z0-9./]+}
          add_message 'Invalid URL'
          return ''
        end
        url
      end

      def validate_user
        user = @request.query_value 'user'
        unless user =~ URI::MailTo::EMAIL_REGEXP
          add_message 'Invalid user'
          return ''
        end
        user
      end

      # @param [String] url
      # @param [SxToken] token
      def access_granted_email(url, token)
        exchange_link = lambda do |t|
          "#{@request.request_scheme}://#{@request.http_host}#{Constants::URL_PREFIX}" \
          "/sx/exchange?token=#{t}&hash=#{t.to_hash}"
        end
        template = Slim::Template.new 'controller/emails/token_exchange.slim'
        template.render(self, { url:, link: exchange_link.call(token), token: })
      end

      # @param [String] user
      # @param [String] url
      # @param [String] text
      def send_mail_and_response(user, url, text)
        send_mail user, url.to_s, text
        template = Slim::Template.new 'controller/views/access_mail_sent.slim'
        html = template.render(self, {})
        @response.success html
      end

      # @param [String] to_address
      # @param [String] url
      # @param [String] html
      def send_mail(to_address, url, html)
        @mail.to to_address
        @mail.subject "Access to #{url}"
        @mail.html_part do
          content_type 'text/html; charset=UTF-8'
          body html
        end
        @mail.deliver
      end
    end
  end
end

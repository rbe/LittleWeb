# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  # Controller
  module Controller
    require_relative '../../http/controller'

    # Secure link request use case
    class AccessRequestController < HTTP::Controller
      require 'cgi/html'
      require 'slim'
      require 'mail'
      require_relative 'constants'
      require_relative '../../http/csrf_token'

      # @param [CGI] cgi
      def initialize(cgi)
        super(cgi)
        @mail = Mail.new do
          delivery_method :smtp,
                          address: Constants::EMAIL_HOST_FQDN,
                          port: Constants::EMAIL_HOST_PORT
          from Constants::EMAIL_FROM
        end
      end

      # Show form to request access
      def render
        bindings = {
          '__csrf_token': HTTP::CsrfToken.new,
          url: @request.request_uri,
          message: @messages.join('<br/>')
        }
        render_view 'views/access_request_form.slim', bindings
      end

      # Process submitted form
      def process
        # return @response.bad_request_response('Invalid token') unless @request.query_value? 'token', 'hash'

        token = create_sx_token
        return render unless token

        user = validate_user
        url = validate_url
        html = access_granted_email(url, token)
        send_mail_and_response(user, url, html)
      end

      private

      def create_sx_token
        user = validate_user
        url = validate_url
        token = Authentication::SxToken.new.with user, url
        return add_message 'No access to URL' unless token.access? user, url

        token
      end

      def validate_url
        url = @request.request_uri
        return add_message 'Invalid URL' unless url =~ %r{[A-Za-z0-9./]+}

        url
      end

      def validate_user
        user = @request.query_value 'user'
        return add_message 'Invalid user' unless user =~ URI::MailTo::EMAIL_REGEXP

        user
      end

      # @param [String] url
      # @param [SxToken] token
      def access_granted_email(url, token)
        exchange_link = lambda do |t|
          "#{ENV['REQUEST_SCHEME']}://#{ENV['HTTP_HOST']}#{Constants::URL_PREFIX}" \
          "/sx_exchange?token=#{t}&hash=#{t.to_hash}"
        end
        template = Slim::Template.new('emails/access_granted.slim')
        template.render(self, { url:, link: exchange_link.call(token), token: })
      end

      # @param [String] user
      # @param [String] url
      # @param [String] text
      def send_mail_and_response(user, url, text)
        send_mail user, url.to_s, text
        template = Slim::Template.new('views/access_granted.slim')
        html = template.render(self, {})
        @response.success_response html
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

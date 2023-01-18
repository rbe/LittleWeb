# frozen_string_literal: true

# sx: Secure Access
module SecureAccess
  require_relative '../http/http_response'
  require_relative 'constants'

  # Secure link request use case
  class LinkRequestForm < HTTP::HttpResponse
    require 'cgi/html'
    require 'mail'

    # Show form to request access
    def render_form
      headers = HTTP::HttpResponse::STD_HEADERS.merge('status' => 200, 'type' => 'text/html')
      @cgi.out(headers) { @cgi.html('LANG' => 'en') { render_form_head + render_form_body } }
    end

    def process_form
      user = @cgi['user']
      url = @cgi['url']
      token = Token.new.with user, url
      return forbidden_reponse "No access to #{url}" unless token.access? user, url

      send_mail_and_response(
        user, url,
        "http://localhost:8080/#{Constants::URL_PREFIX}/sx_exchange?token=#{token}&hash=#{token.to_hash}" +
          "\nExpires: #{token.expires.to_i}"
      )
    end

    private

    def send_mail_and_response(user, url, text)
      send_mail user, url.to_s, text
      success_response 'Check your mails!'
      #rescue StandardError
      #forbidden_reponse 'The server made a boo-boo :-('
    end

    # @param [String] to_address
    # @param [String] url
    # @param [String] text
    def send_mail(to_address, url, text)
      mail = Mail.new do
        delivery_method :smtp,
                        address: Constants::EMAIL_HOST_FQDN,
                        port: Constants::EMAIL_HOST_PORT
        from Constants::EMAIL_FROM
        to to_address
        subject "Access to #{url}"
        body text
      end
      mail.deliver
    end

    def render_form_body
      @cgi.body do
        @cgi.h1 { 'Access Request Form' } +
          @cgi.form('METHOD' => 'POST', 'ENCTYPE' => 'text/json') do
            @cgi.text_field('NAME' => 'url', 'VALUE' => "#{Constants::URL_PREFIX}/IJOS-Stellenportal", 'SIZE' => 50) +
              @cgi.br +
              @cgi.text_field('NAME' => 'user', 'VALUE' => 'ralf@bensmann.com', 'SIZE' => 50) +
              @cgi.br +
              @cgi.submit('ID' => 'btn1', 'NAME' => 'btn1', 'VALUE' => 'OK')
          end
      end
    end

    def render_form_head
      @cgi.head do
        @cgi.title { 'Secure Access' }
      end
    end
  end
end
